# frozen_string_literal: true

class AddCategoryToOpportunities < ActiveRecord::Migration[5.1]
  def change
    add_column :opportunities, :category, :string
  end
end
