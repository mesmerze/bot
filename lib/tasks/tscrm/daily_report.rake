# frozen_string_literal: true

namespace :tscrm do
  desc "Send Daily Reports to Admin Users"
  task daily_report: :environment do
    User.where(admin: true).ids.each do |admin|
      SummaryMailer.daily_report(admin).deliver_now
    end
  end
end
