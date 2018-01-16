# frozen_string_literal: true

class Shop < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  belongs_to :account, optional: true
  has_many :shops_opportunities, dependent: :destroy
  has_many :opportunities, through: :shops_opportunities
  has_many :shops_contacts, dependent: :destroy
  has_many :contacts, through: :shops_contacts

  uses_user_permissions
  sortable by: ["name ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"
  has_ransackable_associations %w[accounts]
  ransack_can_autocomplete
  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]

  scope :text_search, ->(query) { ransack('name_cont' => query).result }

  validates_presence_of :name, message: :missing_name
  validates_uniqueness_of :name
  validates_numericality_of :num_seats, allow_blank: true,
                                        greater_than_or_equal_to: 1,
                                        less_than_or_equal_to: 999

  def attach!(attachment)
    return unless account
    return unless account.send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
    unless send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      send(attachment.class.name.tableize) << attachment
    end
  end

  def discard!(attachment)
    send(attachment.class.name.tableize).delete(attachment)
  end
end
