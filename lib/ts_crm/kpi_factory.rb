# frozen_string_literal: true

class KpiFactory
  LIVE_SHOPS = %w[won setup_qued setup_ongoing setup_training live_pending live_trial live]

  attr_accessor :leads, :opportunities, :closed_opportunities, :proj_opportunities, :live_shops, :expected_revenue,
                :closed_revenue, :scale_backwards, :scale_forward, :scale_middle, :projections, :closed, :target_line, :users

  def initialize(groups, users = [], countries = [])
    process_groups(groups)
    process_users(users)
    @countries = countries
    @user_leads = Lead.where(user: @users)
    @user_opportunities = Opportunity.where(assignee: @users)
    process
  end

  private

  def process_groups(groups)
    @users = if groups.blank?
               User.all
             else
               groups = groups.map(&:to_i).map { |id| id.zero? ? nil : id } # users with group_id nil are unassigned
               User.left_outer_joins(:groups).select('users.*, groups.id as group_id').group_by(&:group_id).slice(*groups).values.flatten.uniq
             end
  end

  def process_users(users)
    @users = users.blank? ? @users : @users.where(id: users.map(&:to_i))
  end

  def process
    set_scales
    calc_leads
    calc_created_opps
    calc_closed_opps
    calc_projected_opps
    calc_live_shops
    calc_expected_revenue
    calc_closed_revenue
    calc_summary
    set_timelines
  end

  def set_scales
    @months_middle = Array.new(12) { |i| (Date.today + 6.months - i.month).beginning_of_month }
    @months_backwards = Array.new(12) { |i| (Date.today - i.month).beginning_of_month }
    @months_forward = Array.new(12) { |i| (Date.today + i.month).beginning_of_month }
  end

  def calc_leads
    created = @user_leads.pluck(:created_at)
    @leads = @months_backwards.reverse.map do |m|
      created.count { |t| (m..m.end_of_month).cover? t }
    end
  end

  def calc_created_opps
    created = @user_opportunities.pluck(:created_at)
    @opportunities = @months_backwards.reverse.map do |m|
      created.count { |t| (m..m.end_of_month).cover? t }
    end
  end

  def calc_closed_opps
    closed = @user_opportunities.pluck(:closes_on)
    @closed_opportunities = @months_backwards.reverse.map do |m|
      closed.count { |t| (m..m.end_of_month).cover? t }
    end
  end

  def calc_projected_opps
    projected = @user_opportunities.pluck(:projected_close_date)
    @proj_opportunities = @months_forward.map do |m|
      projected.count { |t| (m..m.end_of_month).cover? t }
    end
  end

  def calc_live_shops
    shops = @user_opportunities.joins(:shops).pluck('shops.updated_at, shops.stage, shops.country')
    shops = shops.select { |_t, _s, c| @countries.include? c } unless @countries.blank?
    @live_shops = @months_backwards.reverse.map do |m|
      shops.count { |t, s| (m..m.end_of_month).cover?(t) && LIVE_SHOPS.include?(s) }
    end
  end

  def calc_expected_revenue
    opportunities = @user_opportunities.pluck(:projected_close_date, :amount, :probability, :stage)
    projected = @months_forward.map do |m|
      opportunities.select { |t, _a, _p, s| (m..m.end_of_month).cover?(t) && s != 'won' }
    end
    @expected_revenue = projected.map { |m| m.sum { |_t, a, p| a.to_i * p.to_i / 100 } }
  end

  def calc_closed_revenue
    opportunities = @user_opportunities.pluck(:closes_on, :stage, :amount, :probability)
    closed = @months_backwards.reverse.map do |m|
      opportunities.select { |t, s, _a, _p| (m..m.end_of_month).cover?(t) && s == 'won' }
    end
    @closed_revenue = closed.map { |m| m.sum { |_t, _s, a, p| a.to_i * p.to_i / 100 } }
  end

  def calc_summary
    opportunities = @user_opportunities.pluck(:amount, :probability, :projected_close_date, :updated_at, :stage)
    projections = @months_middle.reverse.map do |m|
      if m.end_of_month <= Date.today
        month = m.prev_month.strftime('%Y-%m')
        @users.inject(0) { |sum, user| sum + user.projections[month].to_i }
      else
        opportunities.select do |_a, _p, c, _u, s|
          (m..m.end_of_month).cover?(c) && s != 'won'
        end
      end
    end
    @projections = projections.map { |m| m.is_a?(Array) ? m.sum { |a, p| a.to_i * p.to_i / 100 } : m }
    @closed = @closed_revenue.last(6).concat(Array.new(6, 0))
    target = @users.inject(0) { |sum, user| sum + user.month_revenue.to_i }
    @target_line = Array.new(12, target)
  end

  def set_timelines
    @scale_middle = @months_middle.reverse.map { |m| Date::ABBR_MONTHNAMES[m.month] }.to_json
    @scale_backwards = @months_backwards.reverse.map { |m| Date::ABBR_MONTHNAMES[m.month] }.to_json
    @scale_forward = @months_forward.map { |m| Date::ABBR_MONTHNAMES[m.month] }.to_json
  end
end
