# frozen_string_literal: true

class InstanceFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    if params[:limited].present?
      scope = DomainBlock
      scope = scope.matches_domain(params[:by_domain]) if params[:by_domain].present?
      scope.order(id: :desc)
    else
      scope = Account.remote
      scope = scope.matches_domain(params[:by_domain]) if params[:by_domain].present?
      scope.by_domain_accounts
    end
  end
end
