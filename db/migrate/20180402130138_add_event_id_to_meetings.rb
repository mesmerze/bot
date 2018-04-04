# frozen_string_literal: true

class AddEventIdToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :event_id, :string
  end
end
