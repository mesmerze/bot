# frozen_string_literal: true

class MapAccountCategories < ActiveRecord::Migration[5.1]
  def up
    Account.find_each do |account|
      unless ["customer_restaurant", "customer_hotel", "customer_other", nil].include?(account.category)
        account.category = nil
        account.save!
      end
    end
  end
end
