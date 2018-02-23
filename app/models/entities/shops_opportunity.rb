# frozen_string_literal: true

class ShopsOpportunity < ActiveRecord::Base
  belongs_to :shop
  belongs_to :opportunity
end
