# frozen_string_literal: true

class ProcessMentionsService < BaseService
  include StreamEntryRenderer

  # Scan status for mentions and fetch remote mentioned users, create
  # local mention pointers, send Salmon notifications to mentioned
  # remote users
  # @param [Status] status
  def call(status)
    return unless status.local?

    @status  = status
    mentions = []

    status.text = status.text.gsub(Account::MENTION_RE) do |match|
      username, domain  = Regexp.last_match(1).split('@')
      mentioned_account = Account.find_remote(username, domain)

      if mention_undeliverable?(mentioned_account)
        begin
          mentioned_account = resolve_account_service.call(Regexp.last_match(1))
        rescue Goldfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::UnexpectedResponseError
          mentioned_account = nil
        end
      end

      next match if mention_undeliverable?(mentioned_account) || mentioned_account&.suspended

      mentions << mentioned_account.mentions.where(status: status).first_or_create(status: status)

      "@#{mentioned_account.acct}"
    end

    status.save!

    mentions.each { |mention| create_notification(mention) }
  end

  private

  def mention_undeliverable?(mentioned_account)
    mentioned_account.nil? || (!mentioned_account.local? && mentioned_account.ostatus? && @status.stream_entry.hidden?)
  end

  def create_notification(mention)
    mentioned_account = mention.account

    if mentioned_account.local?
      LocalNotificationWorker.perform_async(mentioned_account.id, mention.id, mention.class.name)
    elsif mentioned_account.ostatus? && !@status.stream_entry.hidden? && !@status.local_only?
      NotificationWorker.perform_async(ostatus_xml, @status.account_id, mentioned_account.id)
    elsif mentioned_account.activitypub? && !@status.local_only?
      ActivityPub::DeliveryWorker.perform_async(activitypub_json, mention.status.account_id, mentioned_account.inbox_url)
    end
  end

  def ostatus_xml
    @ostatus_xml ||= stream_entry_to_xml(@status.stream_entry)
  end

  def activitypub_json
    return @activitypub_json if defined?(@activitypub_json)
    payload = ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::ActivitySerializer,
      adapter: ActivityPub::Adapter
    ).as_json
    @activitypub_json = Oj.dump(@status.distributable? ? ActivityPub::LinkedDataSignature.new(payload).sign!(@status.account) : payload)
  end

  def resolve_account_service
    ResolveAccountService.new
  end
end
