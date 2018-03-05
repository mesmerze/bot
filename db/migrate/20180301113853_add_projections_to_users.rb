# frozen_string_literal: true

class AddProjectionsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :projections, :jsonb, default: {}
  end
end
