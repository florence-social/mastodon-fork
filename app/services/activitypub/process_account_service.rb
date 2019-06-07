# frozen_string_literal: true

class ActivityPub::ProcessAccountService < BaseService
  include JsonLdHelper

  # Should be called with confirmed valid JSON
  # and WebFinger-resolved username and domain
  def call(username, domain, json, options = {})
    return if json['inbox'].blank? || unsupported_uri_scheme?(json['id'])

    @options     = options
    @json        = json
    @uri         = @json['id']
    @username    = username
    @domain      = domain
    @collections = {}

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        @account        = Account.find_remote(@username, @domain)
        @old_public_key = @account&.public_key
        @old_protocol   = @account&.protocol

        create_account if @account.nil?
        update_account
        process_tags
        process_attachments
      else
        raise Mastodon::RaceConditionError
      end
    end

    return if @account.nil?

    after_protocol_change! if protocol_changed?
    after_key_change! if key_changed? && !@options[:signed_with_known_key]
    clear_tombstones! if key_changed?

    unless @options[:only_key]
      check_featured_collection! if @account.featured_collection_url.present?
      check_links! unless @account.fields.empty?
    end

    @account
  rescue Oj::ParseError
    nil
  end

  private

  def create_account
    @account = Account.new
    @account.protocol    = :activitypub
    @account.username    = @username
    @account.domain      = @domain
    @account.suspended   = true if auto_suspend?
    @account.silenced    = true if auto_silence?
    @account.private_key = nil
  end

  def update_account
    @account.last_webfingered_at = Time.now.utc unless @options[:only_key]
    @account.protocol            = :activitypub

    set_immediate_attributes!
    set_fetchable_attributes! unless @options[:only_keys]

    @account.save_with_optional_media!
  end

  def set_immediate_attributes!
    @account.inbox_url               = @json['inbox'] || ''
    @account.outbox_url              = @json['outbox'] || ''
    @account.shared_inbox_url        = (@json['endpoints'].is_a?(Hash) ? @json['endpoints']['sharedInbox'] : @json['sharedInbox']) || ''
    @account.followers_url           = @json['followers'] || ''
    @account.featured_collection_url = @json['featured'] || ''
    @account.url                     = url || @uri
    @account.uri                     = @uri
    @account.display_name            = @json['name'] || ''
    @account.note                    = @json['summary'] || ''
    @account.locked                  = @json['manuallyApprovesFollowers'] || false
    @account.fields                  = property_values || {}
    @account.also_known_as           = as_array(@json['alsoKnownAs'] || []).map { |item| value_or_id(item) }
    @account.actor_type              = actor_type
  end

  def set_fetchable_attributes!
    @account.avatar_remote_url = image_url('icon')  unless skip_download?
    @account.header_remote_url = image_url('image') unless skip_download?
    @account.public_key        = public_key || ''
    @account.statuses_count    = outbox_total_items    if outbox_total_items.present?
    @account.following_count   = following_total_items if following_total_items.present?
    @account.followers_count   = followers_total_items if followers_total_items.present?
    @account.moved_to_account  = @json['movedTo'].present? ? moved_account : nil
  end

  def after_protocol_change!
    ActivityPub::PostUpgradeWorker.perform_async(@account.domain)
  end

  def after_key_change!
    RefollowWorker.perform_async(@account.id)
  end

  def check_featured_collection!
    ActivityPub::SynchronizeFeaturedCollectionWorker.perform_async(@account.id)
  end

  def check_links!
    VerifyAccountLinksWorker.perform_async(@account.id)
  end

  def actor_type
    if @json['type'].is_a?(Array)
      @json['type'].find { |type| ActivityPub::FetchRemoteAccountService::SUPPORTED_TYPES.include?(type) }
    else
      @json['type']
    end
  end

  def image_url(key)
    value = first_of_value(@json[key])

    return if value.nil?
    return value['url'] if value.is_a?(Hash)

    image = fetch_resource_without_id_validation(value)
    image['url'] if image
  end

  def public_key
    value = first_of_value(@json['publicKey'])

    return if value.nil?
    return value['publicKeyPem'] if value.is_a?(Hash)

    key = fetch_resource_without_id_validation(value)
    key['publicKeyPem'] if key
  end

  def url
    return if @json['url'].blank?

    url_candidate = url_to_href(@json['url'], 'text/html')

    if unsupported_uri_scheme?(url_candidate) || mismatching_origin?(url_candidate)
      nil
    else
      url_candidate
    end
  end

  def property_values
    return unless @json['attachment'].is_a?(Array)
    as_array(@json['attachment']).select { |attachment| attachment['type'] == 'PropertyValue' }.map { |attachment| attachment.slice('name', 'value') }
  end

  def mismatching_origin?(url)
    needle   = Addressable::URI.parse(url).host
    haystack = Addressable::URI.parse(@uri).host

    !haystack.casecmp(needle).zero?
  end

  def outbox_total_items
    collection_total_items('outbox')
  end

  def following_total_items
    collection_total_items('following')
  end

  def followers_total_items
    collection_total_items('followers')
  end

  def collection_total_items(type)
    return if @json[type].blank?
    return @collections[type] if @collections.key?(type)

    collection = fetch_resource_without_id_validation(@json[type])

    @collections[type] = collection.is_a?(Hash) && collection['totalItems'].present? && collection['totalItems'].is_a?(Numeric) ? collection['totalItems'] : nil
  rescue HTTP::Error, OpenSSL::SSL::SSLError
    @collections[type] = nil
  end

  def moved_account
    account   = ActivityPub::TagManager.instance.uri_to_resource(@json['movedTo'], Account)
    account ||= ActivityPub::FetchRemoteAccountService.new.call(@json['movedTo'], id: true, break_on_redirect: true)
    account
  end

  def skip_download?
    @account.suspended? || domain_block&.reject_media?
  end

  def auto_suspend?
    domain_block&.suspend?
  end

  def auto_silence?
    domain_block&.silence?
  end

  def domain_block
    return @domain_block if defined?(@domain_block)
    @domain_block = DomainBlock.find_by(domain: @domain)
  end

  def key_changed?
    !@old_public_key.nil? && @old_public_key != @account.public_key
  end

  def clear_tombstones!
    Tombstone.where(account_id: @account.id).delete_all
  end

  def protocol_changed?
    !@old_protocol.nil? && @old_protocol != @account.protocol
  end

  def lock_options
    { redis: Redis.current, key: "process_account:#{@uri}" }
  end

  def process_tags
    return if @json['tag'].blank?

    as_array(@json['tag']).each do |tag|
      process_emoji tag if equals_or_includes?(tag['type'], 'Emoji')
    end
  end

  def process_attachments
    return if @json['attachment'].blank?

    previous_proofs = @account.identity_proofs.to_a
    current_proofs  = []

    as_array(@json['attachment']).each do |attachment|
      next unless equals_or_includes?(attachment['type'], 'IdentityProof')
      current_proofs << process_identity_proof(attachment)
    end

    previous_proofs.each do |previous_proof|
      next if current_proofs.any? { |current_proof| current_proof.id == previous_proof.id }
      previous_proof.delete
    end
  end

  def process_emoji(tag)
    return if skip_download?
    return if tag['name'].blank? || tag['icon'].blank? || tag['icon']['url'].blank?

    shortcode = tag['name'].delete(':')
    image_url = tag['icon']['url']
    uri       = tag['id']
    updated   = tag['updated']
    emoji     = CustomEmoji.find_by(shortcode: shortcode, domain: @account.domain)

    return unless emoji.nil? || image_url != emoji.image_remote_url || (updated && updated >= emoji.updated_at)

    emoji ||= CustomEmoji.new(domain: @account.domain, shortcode: shortcode, uri: uri)
    emoji.image_remote_url = image_url
    emoji.save
  end

  def process_identity_proof(attachment)
    provider          = attachment['signatureAlgorithm']
    provider_username = attachment['name']
    token             = attachment['signatureValue']

    @account.identity_proofs.where(provider: provider, provider_username: provider_username).find_or_create_by(provider: provider, provider_username: provider_username, token: token)
  end
end
