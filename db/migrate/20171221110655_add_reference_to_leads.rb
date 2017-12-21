class AddReferenceToLeads < ActiveRecord::Migration[5.1]
  def change
    add_reference :accounts, :lead, foreign_key: true
  end
end
