# frozen_string_literal: true

class OStatus::Activity::Creation < OStatus::Activity::Base
  def perform
    if redis.exists("delete_upon_arrival:#{@account.id}:#{id}")
      Rails.logger.debug "Delete for status #{id} was queued, ignoring"
      return [nil, false]
    end

    return [nil, false] if @account.suspended? || invalid_origin?

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        # Return early if status already exists in db
        @status = find_status(id)
        return [@status, false] unless @status.nil?
        @status = process_status
      else
        raise Mastodon::RaceConditionError
      end
    end

    [@status, true]
  end

  def process_status
    Rails.logger.debug "Creating remote status #{id}"
    cached_reblog = reblog
    status = nil

    # Skip if the reblogged status is not public
    return if cached_reblog && !(cached_reblog.public_visibility? || cached_reblog.unlisted_visibility?)

    media_attachments = save_media.take(4)

    ApplicationRecord.transaction do
      status = Status.create!(
        uri: id,
        url: url,
        account: @account,
        reblog: cached_reblog,
        text: content,
        spoiler_text: content_warning,
        created_at: published,
        override_timestamps: @options[:override_timestamps],
        reply: thread?,
        language: content_language,
        visibility: visibility_scope,
        conversation: find_or_create_conversation,
        thread: thread? ? find_status(thread.first) || find_activitypub_status(thread.first, thread.second) : nil,
        media_attachment_ids: media_attachments.map(&:id),
        sensitive: sensitive?
      )

      save_mentions(status)
      save_hashtags(status)
      save_emojis(status)
    end

    if thread? && status.thread.nil? && Request.valid_url?(thread.second)
      Rails.logger.debug "Trying to attach #{status.id} (#{id}) to #{thread.first}"
      ThreadResolveWorker.perform_async(status.id, thread.second)
    end

    Rails.logger.debug "Queuing remote status #{status.id} (#{id}) for distribution"

    LinkCrawlWorker.perform_async(status.id) unless status.spoiler_text?

    # Only continue if the status is supposed to have arrived in real-time.
    # Note that if @options[:override_timestamps] isn't set, the status
    # may have a lower snowflake id than other existing statuses, potentially
    # "hiding" it from paginated API calls
    return status unless @options[:override_timestamps] || status.within_realtime_window?

    DistributionWorker.perform_async(status.id)

    status
  end

  def content
    @xml.at_xpath('./xmlns:content', xmlns: OStatus::TagManager::XMLNS).content
  end

  def content_language
    @xml.at_xpath('./xmlns:content', xmlns: OStatus::TagManager::XMLNS)['xml:lang']&.presence || 'en'
  end

  def content_warning
    @xml.at_xpath('./xmlns:summary', xmlns: OStatus::TagManager::XMLNS)&.content || ''
  end

  def visibility_scope
    @xml.at_xpath('./mastodon:scope', mastodon: OStatus::TagManager::MTDN_XMLNS)&.content&.to_sym || :public
  end

  def published
    @xml.at_xpath('./xmlns:published', xmlns: OStatus::TagManager::XMLNS).content
  end

  def thread?
    !@xml.at_xpath('./thr:in-reply-to', thr: OStatus::TagManager::THR_XMLNS).nil?
  end

  def thread
    thr = @xml.at_xpath('./thr:in-reply-to', thr: OStatus::TagManager::THR_XMLNS)
    [thr['ref'], thr['href']]
  end

  private

  def sensitive?
    # OStatus-specific convention (not standard)
    @xml.xpath('./xmlns:category', xmlns: OStatus::TagManager::XMLNS).any? { |category| category['term'] == 'nsfw' }
  end

  def find_or_create_conversation
    uri = @xml.at_xpath('./ostatus:conversation', ostatus: OStatus::TagManager::OS_XMLNS)&.attribute('ref')&.content
    return if uri.nil?

    if OStatus::TagManager.instance.local_id?(uri)
      local_id = OStatus::TagManager.instance.unique_tag_to_local_id(uri, 'Conversation')
      return Conversation.find_by(id: local_id)
    end

    Conversation.find_by(uri: uri) || Conversation.create!(uri: uri)
  end

  def save_mentions(parent)
    processed_account_ids = []

    @xml.xpath('./xmlns:link[@rel="mentioned"]', xmlns: OStatus::TagManager::XMLNS).each do |link|
      next if [OStatus::TagManager::TYPES[:group], OStatus::TagManager::TYPES[:collection]].include? link['ostatus:object-type']

      mentioned_account = account_from_href(link['href'])

      next if mentioned_account.nil? || processed_account_ids.include?(mentioned_account.id)

      mentioned_account.mentions.where(status: parent).first_or_create(status: parent)

      # So we can skip duplicate mentions
      processed_account_ids << mentioned_account.id
    end
  end

  def save_hashtags(parent)
    tags = @xml.xpath('./xmlns:category', xmlns: OStatus::TagManager::XMLNS).map { |category| category['term'] }.select(&:present?)
    ProcessHashtagsService.new.call(parent, tags)
  end

  def save_media
    do_not_download = DomainBlock.reject_media?(@account.domain)
    media_attachments = []

    @xml.xpath('./xmlns:link[@rel="enclosure"]', xmlns: OStatus::TagManager::XMLNS).each do |link|
      next unless link['href']

      media = MediaAttachment.where(status: nil, remote_url: link['href']).first_or_initialize(account: @account, status: nil, remote_url: link['href'])
      parsed_url = Addressable::URI.parse(link['href']).normalize

      next if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.empty?

      media.save
      media_attachments << media

      next if do_not_download

      begin
        media.file_remote_url = link['href']
        media.save!
      rescue ActiveRecord::RecordInvalid
        next
      end
    end

    media_attachments
  end

  def save_emojis(parent)
    do_not_download = DomainBlock.reject_media?(parent.account.domain)

    return if do_not_download

    @xml.xpath('./xmlns:link[@rel="emoji"]', xmlns: OStatus::TagManager::XMLNS).each do |link|
      next unless link['href'] && link['name']

      shortcode = link['name'].delete(':')
      emoji     = CustomEmoji.find_by(shortcode: shortcode, domain: parent.account.domain)

      next unless emoji.nil?

      emoji = CustomEmoji.new(shortcode: shortcode, domain: parent.account.domain)
      emoji.image_remote_url = link['href']
      emoji.save
    end
  end

  def account_from_href(href)
    url = Addressable::URI.parse(href).normalize

    if TagManager.instance.web_domain?(url.host)
      Account.find_local(url.path.gsub('/users/', ''))
    else
      Account.where(uri: href).or(Account.where(url: href)).first || FetchRemoteAccountService.new.call(href)
    end
  end

  def invalid_origin?
    return false unless id.start_with?('http') # Legacy IDs cannot be checked

    needle = Addressable::URI.parse(id).normalized_host

    !(needle.casecmp(@account.domain).zero? ||
      needle.casecmp(Addressable::URI.parse(@account.remote_url.presence || @account.uri).normalized_host).zero?)
  end

  def lock_options
    { redis: Redis.current, key: "create:#{id}" }
  end
end
