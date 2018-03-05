# frozen_string_literal: true

class AnalysisController < ApplicationController
  before_action :set_current_tab, only: :index

  def index
    @users = User.all
    @groups = Group.all.map { |g| [g.name, g.id] } << ['Unassigned group', :unassigned]
  end

  def draw_kpi
    @kpi = KpiFactory.new(params[:groups], params[:users], params[:countries])
    @redraw_users = @kpi.users if params[:redraw].present?

    respond_with(@kpi)
  end
end
