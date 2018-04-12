# frozen_string_literal: true

class CreateAccountSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :account_systems do |t|
      t.references :account, index: true
      t.references :system, index: true
      t.decimal :monthly_cost, precision: 12, scale: 2
      t.date :expiration_date
      t.string :satisfaction
      t.boolean :is_api_required
      t.text :memo

      t.timestamps
    end
  end
end
