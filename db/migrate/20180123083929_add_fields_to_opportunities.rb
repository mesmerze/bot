# frozen_string_literal: true

class AddFieldsToOpportunities < ActiveRecord::Migration[5.1]
  def change
    add_column :opportunities, :projected_close_date, :date
  end
end
