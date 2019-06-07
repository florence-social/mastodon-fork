# frozen_string_literal: true

class ActivityPub::FlagSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :content
  attribute :virtual_object, key: :object

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'Flag'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(instance_options[:account] || object.account)
  end

  def virtual_object
    [ActivityPub::TagManager.instance.uri_for(object.target_account)] + object.statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) }
  end

  def content
    object.comment
  end
end
