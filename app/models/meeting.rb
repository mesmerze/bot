# frozen_string_literal: true

class Meeting < ApplicationRecord
  self.skip_time_zone_conversion_for_attributes = [:meeting_start]

  FILE_TYPES = %w[application/msword
                  application/pdf
                  text/csv
                  application/vnd.ms-excel
                  application/vnd.openxmlformats-officedocument.wordprocessingml.document
                  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet].freeze

  belongs_to :user
  belongs_to :assignee, class_name: 'User', foreign_key: :assigned_to
  belongs_to :account

  has_one_attached :document

  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]

  validate :correct_document_mime_type, on: %i[create update]
  validates_presence_of :name, message: :missing_meeting_name
  validates_presence_of :assigned_to, message: :missing_assigned_user
  validates_presence_of :meeting_start, message: :missing_meeting_date
  validates_presence_of :account_id, message: :missing_account, on: %i[create update]
  validates_presence_of :timezone, message: :missing_timezone
  validates_inclusion_of :meeting_type, in: Setting.meeting_type.map(&:to_s), allow_blank: true

  scope :upcoming, -> { where('meetings.meeting_start >= ?', Date.current) }
  scope :done, -> { where('meetings.meeting_start < ?', Date.current) }

  before_save :nullify_blank_type

  def attachment?
    document.attached? && document.attachment.blob.present? # HACK: need to remove this after activestorage will be fixed
  end

  private

  def nullify_blank_type
    self.meeting_type = nil if meeting_type.blank?
  end

  def correct_document_mime_type
    if document.attached? && !document.content_type.in?(FILE_TYPES)
      errors.add(:document, 'Must be a PDF, CSV, DOC, DOCX, XLS, XLSX file')
    end
  end
end
