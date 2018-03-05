# frozen_string_literal: true

namespace :tscrm do
  desc "Save projections for users"
  task save_projections: :environment do
    begin
      # we want to save projections for next month of each user
      next_month = Date.today.next_month.beginning_of_month..Date.today.next_month.end_of_month
      User.all.each do |user|
        sum = Opportunity.where(assignee: user, projected_close_date: next_month)
                         .sum('amount*probability/100')
        user.projections[Date.today.strftime('%Y-%m')] = sum.to_i
        user.save && print(".")
      end
    rescue StandartError => e
      puts "Error while saving projections: #{e.message}"
      logger.fatal "Error while saving projections: #{e.message}"
    end
  end
end
