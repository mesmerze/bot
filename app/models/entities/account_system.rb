# frozen_string_literal: true

class AccountSystem < ActiveRecord::Base
  belongs_to :account
  belongs_to :system

  validates_presence_of :account_id, :system_id
  validates_presence_of :expiration_date, if: :tms?
  validates_inclusion_of :satisfaction, in: Setting.satisfaction.map(&:to_s), if: :tms?

  before_save :populate_cost

  def populate_cost
    self.monthly_cost = system.monthly_cost
  end

  def update_and_handle_types(params)
    unless params[:expiration_date] && params[:satisfaction]
      self.expiration_date = nil
      self.satisfaction = nil
      return update_attributes(params)
    end
    update_attributes(params)
  end

  private

  def tms?
    system.system_type == 'tms'
  end
end
