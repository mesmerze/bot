# frozen_string_literal: true

class CreateShopsOpportunities < ActiveRecord::Migration[5.1]
  def change
    create_table :shops_opportunities do |t|
      t.references :shop
      t.references :opportunity
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
