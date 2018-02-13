# frozen_string_literal: true

class AnalysisController < ApplicationController
  before_action :set_current_tab, only: :index

  def index
    @users = User.all
  end

  def draw_kpi
    @kpi = KpiFactory.new(params[:user_id], params[:countries])

    respond_with(@kpi)
  end
end
