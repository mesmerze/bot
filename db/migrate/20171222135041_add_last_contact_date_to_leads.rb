class AddLastContactDateToLeads < ActiveRecord::Migration[5.1]
  def change
    add_column :leads, :last_contact_date, :date
  end
end
