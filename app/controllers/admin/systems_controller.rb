# frozen_string_literal: true

class Admin::SystemsController < Admin::ApplicationController
  before_action :setup_current_tab, only: %i[index]

  load_resource

  def index
    @systems = System.all.order(:name)
    respond_with @systems
  end

  def new
    respond_with @system
  end

  def create
    @system.attributes = system_params
    respond_with @system do
      @system.save
    end
  end

  def edit
    respond_with @system
  end

  def update
    respond_with @system do
      @system.update(system_params)
    end
  end

  def destroy
    @system.destroy
    respond_with @system
  end

  def auto_complete
    @query = params[:term]
    @auto_complete = klass.text_search(@query)
                          .limit(10)
                          .map(&:maker)
                          .uniq.to_json

    render json: @auto_complete
  end

  private

  def system_params
    params.require(:system).permit(:name, :maker, :system_type, :monthly_cost, :has_api_realtime, :has_api_batch)
  end

  def setup_current_tab
    set_current_tab('admin/systems')
  end
end
