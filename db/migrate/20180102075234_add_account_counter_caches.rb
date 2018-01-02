class AddAccountCounterCaches < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :contacts_count, :integer, default: 0
    add_column :accounts, :opportunities_count, :integer, default: 0
  end
end
