class AddFieldsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :account_type, :string
    add_column :accounts, :country, :string
    add_column :accounts, :online_review, :decimal, precision: 3, scale: 2
  end
end
