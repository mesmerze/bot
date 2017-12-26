class AddReferencesToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_reference :accounts, :org, index: true
  end
end
