# frozen_string_literal: true

FactoryBot.define do
  factory :org do
    assigned_to nil
    name                { FFaker::Company.name }
    category            { Setting.org_category.map(&:to_s).sample }
    business_scope      { Setting.business_scope.map(&:to_s).sample }
    access "Public"
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end
end
