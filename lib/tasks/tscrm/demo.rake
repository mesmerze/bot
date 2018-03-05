# frozen_string_literal: true

namespace :tscrm do
  desc "Save projections for DEMO users"
  task demo_projections: :environment do
    1.upto(6) do |i|
      date = Date.today - i.months
      next_month = date.next_month.beginning_of_month..date.next_month.end_of_month
      User.all.each do |user|
        sum = Opportunity.where(assignee: user, projected_close_date: next_month)
                         .sum('amount*probability/100')
        user.projections[date.strftime('%Y-%m')] = sum.to_i
        user.save && print(".")
      end
    end
  end

  desc "Load demo data"
  task load_demo: :environment do
    Rake::Task["ffcrm:demo:load"].invoke
    Rake::Task["tscrm:demo_projections"].invoke
  end
end
