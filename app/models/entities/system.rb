# frozen_string_literal: true

class System < ActiveRecord::Base
  has_many :account_systems, dependent: :destroy
  has_many :accounts, through: :account_systems

  validates_uniqueness_of :name
  validates_presence_of :name, message: :missing_system_name
  validates_inclusion_of :system_type, in: Setting.system_types.map(&:to_s)
  validates_numericality_of :monthly_cost, greater_than_or_equal_to: 0, allow_nil: true

  ransack_can_autocomplete

  scope :text_search, ->(query) { ransack('maker_cont' => query).result }

  around_update :populate_cost

  def populate_cost
    if monthly_cost != monthly_cost_was
      account_systems.update_all(monthly_cost: monthly_cost)
    end
    yield
  end

  class << self
    def options
      options = []
      systems = System.all.select(:id, :name, :maker, :system_type).group_by(&:system_type)
      systems.each do |group|
        options << OpenStruct.new(name: group.first&.upcase, systems: group.second.map { |system| system_opt(system) })
      end && options
    end

    def system_opt(system)
      OpenStruct.new(name: system.maker + ': ' + system.name, id: system.id)
    end
  end
end
