class AddReferenceToLeads < ActiveRecord::Migration[5.1]
  def change
    add_reference :leads, :account, foreign_key: true
  end
end
