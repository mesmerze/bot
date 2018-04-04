# frozen_string_literal: true

require 'mail'
class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      mail = Mail::Address.new(value)
      result = mail.domain.present? && Setting.email_domains.include?(mail.domain)
    rescue # rubocop:disable Style/RescueStandardError
      result = false
    end
    record.errors[attribute] << I18n.t(:wrong_domain, emails: Setting.email_domains.join(', ')) unless result
  end
end
