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

  attr_accessor :retroactive

  validates :domain, presence: true, uniqueness: true

  has_many :accounts, foreign_key: :domain, primary_key: :domain
  delegate :count, to: :accounts, prefix: true

  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }

  def self.blocked?(domain)
    where(domain: domain, severity: :suspend).exists?
  end
end
