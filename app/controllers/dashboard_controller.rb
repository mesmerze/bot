# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action -> { set_current_tab(:tab_team) }, only: :index
  before_action :set_sort_options, only: %i[index redraw opportunities]
  before_action :load_ransack_search, only: :index
  before_action :search_for_opportunities, only: %i[index redraw]
  before_action :data_for_sidebar, only: %i[index redraw]
  before_action :set_stages, only: %i[index redraw]

  def index
    @groups = Group.all.order("name")
    @users_with_opportunities = User.joins(:groups)
                                    .where('groups.id IN (?)', @groups.ids)
                                    .have_assigned_opportunities.select('groups.id as group_id, groups.name as group_name')
                                    .order('groups.name, users.first_name')
                                    .current_user_first(current_user).group_by(&:group_id)
    @unassigned_opportunities = Opportunity.my(current_user).unassigned.pipeline.order(:stage).includes(:account, :user, :tags)

    respond_to do |format|
      format.html
      format.js { render 'redraw' }
    end
  end

  def redraw
    group_ids = params[:groups].map(&:to_i)
    user_ids = params[:users].map(&:to_i)
    @users_with_opportunities = User.joins(:groups)
                                    .where('groups.id IN (?) AND users.id IN (?)', group_ids, user_ids)
                                    .have_assigned_opportunities.select('groups.id as group_id, groups.name as group_name')
                                    .order('groups.name, users.first_name').includes(:opportunities)
                                    .current_user_first(current_user).group_by(&:group_id)
    @groups = Group.where(id: group_ids).order("name")
    respond_to do |format|
      format.js
    end
  end

  def opportunities
    user = User.find(params[:id])
    opportunities = user.assigned_opportunities
                        .includes(:user, :tasks, :comments, :account, :tags, :emails, account: { account_systems: :system })
                        .where(id: params[:ids]&.map(&:to_i), stage: params[:stages])
                        .stage_sort.order(params[:sort])

    respond_to do |format|
      if opportunities.blank?
        format.html { render partial: 'empty' }
      else
        format.html { render partial: "dashboard/opportunity", collection: opportunities, locals: { user: user, opportunities: opportunities } }
      end
    end
  end

  protected

  def set_sort_options
    @options_for_sort = Opportunity.sort_by_map.map { |k, v| [t("option_#{k}".to_sym), v] }
    @sort_by = params[:sort] || 'stage_sort ASC'
  end

  def search_for_opportunities
    query = params[:query]
    advanced_search = params[:q]

    @searched_ids = if query.present?
                      load_ransack_search.result.text_search(query).ids
                    elsif advanced_search.present?
                      load_ransack_search.result.ids
                    else
                      Opportunity.all.ids
                    end
    @stages = params[:stages] || Setting.opportunity_stage.without(:lost)
    @search_results_count = @searched_ids.size
  end

  def data_for_sidebar
    @stage = Setting.unroll(:opportunity_stage)
    @opportunity_stage_total = HashWithIndifferentAccess[
                               all: @search_results_count,
                               other: 0
    ]
    stages = @stage.map do |_value, key|
      @opportunity_stage_total[key] = 0
      key
    end
    stage_counts = Opportunity.where(id: @searched_ids, stage: stages).group(:stage).count
    stage_counts.each do |key, total|
      @opportunity_stage_total[key.to_sym] = total
      @opportunity_stage_total[:other] -= total
    end
    @opportunity_stage_total[:other] += @opportunity_stage_total[:all]
  end

  def set_stages
    session[:opportunities_filter] = params[:stages] if params[:stages]
  end
end
