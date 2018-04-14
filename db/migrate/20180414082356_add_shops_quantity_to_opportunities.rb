# frozen_string_literal: true

class AddShopsQuantityToOpportunities < ActiveRecord::Migration[5.2]
  def change
    add_column :opportunities, :shops_count, :integer
  end
end
