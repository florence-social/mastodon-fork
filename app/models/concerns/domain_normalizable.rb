# frozen_string_literal: true

module DomainNormalizable
  extend ActiveSupport::Concern

  included do
    before_save :normalize_domain
  end

  private

  def normalize_domain
    self.domain = TagManager.instance.normalize_domain(domain&.strip)
  end
end
