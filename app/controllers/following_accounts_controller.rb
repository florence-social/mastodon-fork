# frozen_string_literal: true

class FollowingAccountsController < ApplicationController
  include AccountControllerConcern

  before_action :set_cache_headers

  def index
    respond_to do |format|
      format.html do
        mark_cacheable! unless user_signed_in?

        next if @account.user_hides_network?

        follows
        @relationships = AccountRelationshipsPresenter.new(follows.map(&:target_account_id), current_user.account_id) if user_signed_in?
      end

      format.json do
        raise Mastodon::NotPermittedError if params[:page].present? && @account.user_hides_network?

        if params[:page].blank?
          skip_session!
          expires_in 3.minutes, public: true
        end

        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def follows
    @follows ||= Follow.where(account: @account).recent.page(params[:page]).per(FOLLOW_PER_PAGE).preload(:target_account)
  end

  def page_url(page)
    account_following_index_url(@account, page: page) unless page.nil?
  end

  def collection_presenter
    if params[:page].present?
      ActivityPub::CollectionPresenter.new(
        id: account_following_index_url(@account, page: params.fetch(:page, 1)),
        type: :ordered,
        size: @account.following_count,
        items: follows.map { |f| ActivityPub::TagManager.instance.uri_for(f.target_account) },
        part_of: account_following_index_url(@account),
        next: page_url(follows.next_page),
        prev: page_url(follows.prev_page)
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: account_following_index_url(@account),
        type: :ordered,
        size: @account.following_count,
        first: page_url(1)
      )
    end
  end
end
