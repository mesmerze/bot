# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  factory :shop do
    account
    assigned_to nil
    name                { FFaker::Company.name + rand(100).to_s }
    num_seats           { FFaker::Random.rand(1..999) }
    stage               { Setting.shop_stage.map(&:to_s).sample }
    access "Public"
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end

  factory :shop_opportunity do
    shop
    opportunity
    deleted_at nil
    updated_at          { FactoryBot.generate(:time) }
    created_at          { FactoryBot.generate(:time) }
  end
end
