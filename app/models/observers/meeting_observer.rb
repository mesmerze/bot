# frozen_string_literal: true

class MeetingObserver < ActiveRecord::Observer
  require 'google/api_client/client_secrets.rb'

  observe :meeting

  def after_create(item)
    init_client(item) && create_event
    push_event
  end

  def after_update(item)
    init_client(item) && create_event
    if event_sent_before?
      patch_event
    else
      push_event
    end
  end

  def after_destroy(item)
    init_client(item)
    delete_event if event_sent_before?
  end

  private

  def event_sent_before?
    @client.get_event(@item.user.email, @item.event_id) do |result, err|
      err ? Rails.logger.fatal(err) && nil : result
    end&.id.present?
  end

  def can_send_event?
    @item.user.oauth_token.present? && @item.user.refresh_token.present?
  end

  def init_client(item)
    @item = item
    secrets = Google::APIClient::ClientSecrets.new(
      web: { access_token: @item.user.oauth_token,
             refresh_token: @item.user.refresh_token,
             client_id: ENV['GOOGLE_OAUTH2_CLIENT_ID'],
             client_secret: ENV['GOOGLE_OAUTH2_CLIENT_SECRET'] }
    )

    @client = Google::Apis::CalendarV3::CalendarService.new
    @client.authorization = secrets.to_authorization
  end

  def create_event
    @event = Google::Apis::CalendarV3::Event.new
    @event.summary = I18n.t(:ts_crm) + ': ' + @item.name
    @event.color_id = 2
    @event.description = @item.summary
    @event.start = { date_time: @item.meeting_start.strftime("%FT%T"),
                     time_zone: ActiveSupport::TimeZone[@item.timezone].tzinfo.name }
    @event.end = { date_time: (@item.meeting_start + 1.hour).strftime("%FT%T"),
                   time_zone: ActiveSupport::TimeZone[@item.timezone].tzinfo.name }
    @event.attendees = [{ email: @item.assignee.email }] if @item.user != @item.assignee
  end

  def push_event
    @client.insert_event(@item.user.email, @event, send_notifications: true, max_attendees: 1) do |result, err|
      @item.update_column('event_id', result.id) if result
      return result if result
      Rails.logger.fatal(err)
    end
  end

  def patch_event
    @client.patch_event(@item.user.email, @item.event_id, @event, send_notifications: true, max_attendees: 1) do |result, err|
      return result if result
      Rails.logger.fatal(err)
    end
  end

  def delete_event
    @client.delete_event(@item.user.email, @item.event_id, send_notifications: true) do |result, err|
      return result if result
      Rails.logger.fatal(err)
    end
  end
end
