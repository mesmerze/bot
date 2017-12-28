class OrgAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :org_accounts do |t|
      t.references :account
      t.references :org
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
