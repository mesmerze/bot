# frozen_string_literal: true

class ShopsContact < ActiveRecord::Base
  belongs_to :shop
  belongs_to :contact
end
