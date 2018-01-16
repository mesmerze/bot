# frozen_string_literal: true

class Org < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  has_many :sub_orgs, class_name: 'Org', foreign_key: 'org_id'
  has_many :org_accounts, dependent: :destroy
  has_many :accounts, through: :org_accounts
  has_many :emails, as: :mediator

  default_scope { Org.left_outer_joins(accounts: :opportunities).group("orgs.id").select("orgs.*, sum(opportunities.amount) as revenue") }

  serialize :subscribed_users, Set
  accepts_nested_attributes_for :accounts, allow_destroy: true
  accepts_nested_attributes_for :org_accounts, allow_destroy: true

  uses_user_permissions
  uses_comment_extensions
  acts_as_commentable
  has_fields
  acts_as_taggable_on :tags
  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]
  sortable by: ["name ASC", "revenue", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w[accounts emails]
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_name
  validates_uniqueness_of :name
  validates_inclusion_of :category, in: Setting.org_category.map(&:to_s), message: :bad_category
  validates_inclusion_of :business_scope, in: Setting.business_scope.map(&:to_s), allow_blank: true

  def accounts_attributes=(attributes)
    attributes = attributes.invert.invert.with_indifferent_access # Remove duplications
    attributes.delete_if { |_k, v| v["_destroy"].false? && accounts.find_by(id: v["id"]) }
    accounts << attributes.map { |_k, v| Account.find(v[:id]) } # Preferably finding accounts should be scoped
    super
  end
end
