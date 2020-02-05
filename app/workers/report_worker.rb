# frozen_string_literal: true

class ReportWorker
  include Sidekiq::Worker

  def perform(source_account_id, target_account_username, target_account_domain, options = {})
    ReportService.new.call(
      Account.find(source_account_id),
      Account.find_by(domain: target_account_domain, username: target_account_username),
      options
    )
  end
end
