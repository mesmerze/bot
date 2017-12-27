class Org < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  has_many :sub_orgs, class_name: 'Org', foreign_key: 'org_id'
  has_many :accounts, inverse_of: :org

  serialize :subscribed_users, Set
  accepts_nested_attributes_for :accounts, allow_destroy: true

  uses_user_permissions
  uses_comment_extensions
  acts_as_commentable
  has_fields
  acts_as_taggable_on :tags
  sortable by: ["name ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w[accounts]
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_name
  validates_uniqueness_of :name
  validates :category, inclusion: { in: %w[hotel restaurant other] }, allow_blank: true
  validates :business_scope, inclusion: { in: %w[global regional country] }, allow_blank: true

  def accounts_attributes=(attributes)
    accounts << attributes.map { |_k, v| Account.find(v[:id]) } # Preferably finding accounts should be scoped
    super
  end
end
