# frozen_string_literal: true

class RevertCounterCaches < ActiveRecord::Migration[5.1]
  def change
    remove_column :accounts, :pipeline_opportunities_count
  end
end
