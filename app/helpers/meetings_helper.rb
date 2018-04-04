# frozen_string_literal: true

module MeetingsHelper
  def meetings_user_checkbox(value)
    onclick = %{
      var users = [];
      $('input[name=&quot;user[]&quot;]').filter(':checked').each(function () {
        users.push(this.value);
      });
      meetings = $('.flip_meetings.active').data('meetings-index')
      $('#loading').show();
      $('#overlay').show();
      $.get('/meetings.js', { users: users, meetings: meetings }, function () {
        $('#loading').hide();
        $('#overlay').hide();
      });
    }.html_safe
    check_box_tag("user[]", value, true, id: "checkbox_user_#{value}", onclick: onclick)
  end

  def parse_time(meeting)
    correct_utc = Time.use_zone(meeting.timezone) { Time.zone.local_to_utc(meeting.meeting_start) }
    if session[:timezone_offset]
      correct_utc.in_time_zone(ActiveSupport::TimeZone[session[:timezone_offset]]&.name)
    else
      correct_utc.localtime
    end
  end
end
