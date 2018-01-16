# frozen_string_literal: true

class CreateShopsContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :shops_contacts do |t|
      t.references :shop
      t.references :contact
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
