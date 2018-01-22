# frozen_string_literal: true

class RemoveAccountType < ActiveRecord::Migration[5.1]
  def change
    remove_column :accounts, :account_type, :string
  end
end
