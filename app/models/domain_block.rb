# frozen_string_literal: true
# == Schema Information
#
# Table name: domain_blocks
#
#  id             :bigint(8)        not null, primary key
#  domain         :string           default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  severity       :integer          default("silence")
#  reject_media   :boolean          default(FALSE), not null
#  reject_reports :boolean          default(FALSE), not null
#

class DomainBlock < ApplicationRecord
  include DomainNormalizable

  enum severity: [:silence, :suspend, :noop]

  validates :domain, presence: true, uniqueness: true

  has_many :accounts, foreign_key: :domain, primary_key: :domain
  delegate :count, to: :accounts, prefix: true

  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }

  class << self
    def suspend?(domain)
      !!rule_for(domain)&.suspend?
    end

    def silence?(domain)
      !!rule_for(domain)&.silence?
    end

    def reject_media?(domain)
      !!rule_for(domain)&.reject_media?
    end

    def reject_reports?(domain)
      !!rule_for(domain)&.reject_reports?
    end

    alias blocked? suspend?

    def rule_for(domain)
      return if domain.blank?

      uri      = Addressable::URI.new.tap { |u| u.host = domain.gsub(/[\/]/, '') }
      segments = uri.normalized_host.split('.')
      variants = segments.map.with_index { |_, i| segments[i..-1].join('.') }

      where(domain: variants[0..-2]).order(Arel.sql('char_length(domain) desc')).first
    end
  end

  def stricter_than?(other_block)
    return true  if suspend?
    return false if other_block.suspend? && (silence? || noop?)
    return false if other_block.silence? && noop?

    (reject_media || !other_block.reject_media) && (reject_reports || !other_block.reject_reports)
  end

  def affected_accounts_count
    scope = suspend? ? accounts.where(suspended_at: created_at) : accounts.where(silenced_at: created_at)
    scope.count
  end
end
