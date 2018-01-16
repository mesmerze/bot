# frozen_string_literal: true

class ShopsContact < ApplicationRecord
  belongs_to :shop
  belongs_to :contact
end
