# frozen_string_literal: true

class CreateShops < ActiveRecord::Migration[5.1]
  def change
    create_table :shops do |t|
      t.string :name
      t.integer :num_seats
      t.string :access, default: "Public"
      t.text :subscribed_users
      t.integer :assigned_to
      t.references :account, index: true

      t.timestamps
    end
  end
end
