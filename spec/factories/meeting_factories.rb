# frozen_string_literal: true

FactoryBot.define do
  factory :meeting do
    user
    account
    assigned_to nil
    name                { FFaker::Company.name + rand(100).to_s }
    meeting_type        { Setting.meeting_type.sample }
    important false
    timezone            { FFaker::Address.time_zone }
    meeting_start       { Time.current.utc + 10.days }
    summary             { FFaker::Lorem.paragraph[0, 255] }
    access "Public"
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }

    trait :done do
      meeting_start     { Time.current.utc - 10.days }
    end
  end
end
