class CreateOrgs < ActiveRecord::Migration[5.1]
  def change
    create_table :orgs do |t|
      t.string :name
      t.string :category
      t.string :business_scope, default: 'country'
      t.integer :assigned_to
      t.references :org
      t.references :user

      t.timestamps
    end

    add_index :orgs, %i[user_id name org_id]
    add_index :orgs, :assigned_to
  end
end
