# frozen_string_literal: true

namespace :tscrm do
  desc "Send Weekly Reports to Admin Users"
  task weekly_report: :environment do
    User.where(admin: true).ids.each do |admin|
      SummaryMailer.weekly_report(admin).deliver_now
    end
  end
end
