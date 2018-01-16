# frozen_string_literal: true

class AddUserIdToShops < ActiveRecord::Migration[5.1]
  def change
    add_reference :shops, :user
  end
end
