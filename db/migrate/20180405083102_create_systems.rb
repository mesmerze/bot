# frozen_string_literal: true

class CreateSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :systems do |t|
      t.string :name, null: false, index: true
      t.string :maker
      t.string :system_type, null: false
      t.decimal :monthly_cost, precision: 12, scale: 2
      t.boolean :has_api_realtime, null: false, default: false
      t.boolean :has_api_batch, null: false, default: false
      t.string :access, default: "Public"
      t.text :subscribed_users

      t.timestamps
    end
  end
end
