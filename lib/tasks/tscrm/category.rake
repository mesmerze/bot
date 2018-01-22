# frozen_string_literal: true

namespace :tscrm do
  desc "Update current account categories"
  task update_category: :environment do
    accounts = Account.all
    puts "Going to update #{accounts.count} accounts"

    ActiveRecord::Base.transaction do
      accounts.each do |account|
        account.category = case account.account_type
                           when 'restaurant' then 'customer_restaurant'
                           when 'hotel' then 'customer_hotel'
                           when 'other' then 'customer_other'
                           else nil
                           end
        account.save!
        print "."
      end
    end

    puts " All done now!"
  end
end
