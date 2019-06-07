# frozen_string_literal: true

class Import::RelationshipWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 8, dead: false

  def perform(account_id, target_account_uri, relationship, options = {})
    from_account   = Account.find(account_id)
    target_account = ResolveAccountService.new.call(target_account_uri)
    options.symbolize_keys!

    return if target_account.nil?

    case relationship
    when 'follow'
      FollowService.new.call(from_account, target_account, options)
    when 'unfollow'
      UnfollowService.new.call(from_account, target_account)
    when 'block'
      BlockService.new.call(from_account, target_account)
    when 'unblock'
      UnblockService.new.call(from_account, target_account)
    when 'mute'
      MuteService.new.call(from_account, target_account, options)
    when 'unmute'
      UnmuteService.new.call(from_account, target_account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
