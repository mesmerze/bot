class Org < ApplicationRecord
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  has_many :sub_orgs, class_name: 'Org', foreign_key: 'org_id'
  has_many :accounts

  uses_user_permissions
  acts_as_commentable
  acts_as_taggable_on :tags
  sortable by: ["name ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  validates_presence_of :name, message: :missing_name
  validates_uniqueness_of :name
  validates :category, inclusion: { in: %w[hotel restaurant other] }, allow_blank: true
  validates :business_scope, inclusion: { in: %w[global regional country] }, allow_blank: true
end
