# frozen_string_literal: true

class OrgAccount < ActiveRecord::Base
  belongs_to :org
  belongs_to :account
end
