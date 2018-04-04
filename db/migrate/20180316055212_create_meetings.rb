# frozen_string_literal: true

class CreateMeetings < ActiveRecord::Migration[5.2]
  def change
    create_table :meetings do |t|
      t.string :name, null: false, default: ''
      t.string :meeting_type
      t.references :account, index: true
      t.references :user, index: true
      t.datetime :meeting_start, null: false
      t.string :timezone, null: false
      t.integer :assigned_to, index: true
      t.boolean :important, null: false, default: false
      t.text :summary
      t.string :access, default: "Public"

      t.timestamps
    end
  end
end
