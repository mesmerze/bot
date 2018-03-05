# frozen_string_literal: true

require 'tzinfo'
require File.expand_path(File.dirname(__FILE__) + '/environment')
set :output, "log/cron_log.log"
env :PATH, ENV['PATH']

def local(time)
  TZInfo::Timezone.get("Asia/Tokyo").local_to_utc(Time.parse(time))
end

every :weekday, at: local('8:30pm') do
  rake "tscrm:daily_report"
end

every :friday, at: local('8:30pm') do
  rake "tscrm:weekly_report"
end

every "0 0 28-31 * *" do
  rake "tscrm:save_projections"
end
