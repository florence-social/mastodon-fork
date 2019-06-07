# frozen_string_literal: true

class NotifyService < BaseService
  def call(recipient, activity)
    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, activity: @activity)

    return if recipient.user.nil? || blocked?

    create_notification!
    push_notification! if @notification.browserable?
    push_to_conversation! if direct_message?
    send_email! if email_enabled?
  rescue ActiveRecord::RecordInvalid
    return
  end

  private

  def blocked_mention?
    FeedManager.instance.filter?(:mentions, @notification.mention.status, @recipient.id)
  end

  def blocked_favourite?
    false
  end

  def blocked_follow?
    false
  end

  def blocked_reblog?
    false
  end

  def blocked_follow_request?
    false
  end

  def blocked_poll?
    false
  end

  def following_sender?
    return @following_sender if defined?(@following_sender)
    @following_sender = @recipient.following?(@notification.from_account) || @recipient.requested?(@notification.from_account)
  end

  def optional_non_follower?
    @recipient.user.settings.interactions['must_be_follower']  && !@notification.from_account.following?(@recipient)
  end

  def optional_non_following?
    @recipient.user.settings.interactions['must_be_following'] && !following_sender?
  end

  def message?
    @notification.type == :mention
  end

  def direct_message?
    message? && @notification.target_status.direct_visibility?
  end

  def response_to_recipient?
    @notification.target_status.in_reply_to_account_id == @recipient.id && @notification.target_status.thread&.direct_visibility?
  end

  def from_staff?
    @notification.from_account.local? && @notification.from_account.user.present? && @notification.from_account.user.staff?
  end

  def optional_non_following_and_direct?
    direct_message? &&
      @recipient.user.settings.interactions['must_be_following_dm'] &&
      !following_sender? &&
      !response_to_recipient?
  end

  def hellbanned?
    @notification.from_account.silenced? && !following_sender?
  end

  def from_self?
    @recipient.id == @notification.from_account.id
  end

  def domain_blocking?
    @recipient.domain_blocking?(@notification.from_account.domain) && !following_sender?
  end

  def blocked?
    blocked   = @recipient.suspended?                            # Skip if the recipient account is suspended anyway
    blocked ||= from_self? && @notification.type != :poll        # Skip for interactions with self

    return blocked if message? && from_staff?

    blocked ||= domain_blocking?                                 # Skip for domain blocked accounts
    blocked ||= @recipient.blocking?(@notification.from_account) # Skip for blocked accounts
    blocked ||= @recipient.muting_notifications?(@notification.from_account)
    blocked ||= hellbanned?                                      # Hellban
    blocked ||= optional_non_follower?                           # Options
    blocked ||= optional_non_following?                          # Options
    blocked ||= optional_non_following_and_direct?               # Options
    blocked ||= conversation_muted?
    blocked ||= send("blocked_#{@notification.type}?")           # Type-dependent filters
    blocked
  end

  def conversation_muted?
    if @notification.target_status
      @recipient.muting_conversation?(@notification.target_status.conversation)
    else
      false
    end
  end

  def create_notification!
    @notification.save!
  end

  def push_notification!
    return if @notification.activity.nil?

    Redis.current.publish("timeline:#{@recipient.id}", Oj.dump(event: :notification, payload: InlineRenderer.render(@notification, @recipient, :notification)))
    send_push_notifications!
  end

  def push_to_conversation!
    return if @notification.activity.nil?
    AccountConversation.add_status(@recipient, @notification.target_status)
  end

  def send_push_notifications!
    subscriptions_ids = ::Web::PushSubscription.where(user_id: @recipient.user.id)
                                               .select { |subscription| subscription.pushable?(@notification) }
                                               .map(&:id)

    ::Web::PushNotificationWorker.push_bulk(subscriptions_ids) do |subscription_id|
      [subscription_id, @notification.id]
    end
  end

  def send_email!
    return if @notification.activity.nil?
    NotificationMailer.public_send(@notification.type, @recipient, @notification).deliver_later(wait: 2.minutes)
  end

  def email_enabled?
    @recipient.user.settings.notification_emails[@notification.type.to_s]
  end
end
