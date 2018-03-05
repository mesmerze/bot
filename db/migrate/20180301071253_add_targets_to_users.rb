# frozen_string_literal: true

class AddTargetsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :month_revenue, :integer
    add_column :users, :month_shops, :integer
  end
end
