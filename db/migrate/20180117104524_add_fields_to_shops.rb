# frozen_string_literal: true

class AddFieldsToShops < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :country, :string
    add_column :shops, :closed_date, :date
    add_column :shops, :stage, :string
  end
end
