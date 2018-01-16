# frozen_string_literal: true

class ShopsOpportunity < ApplicationRecord
  belongs_to :shop
  belongs_to :opportunity
end
