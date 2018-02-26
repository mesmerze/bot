# frozen_string_literal: true

class ShopsController < EntitiesController
  def index
    @shops = get_shops(page: params[:page])

    respond_with @shops
  end

  def show
    @comment = Comment.new
    @timeline = timeline(@shop)
    respond_with(@shop) do |format|
      format.json { render json: @shop.to_json }
    end
  end

  def new
    @shop.attributes = { user: current_user, access: Setting.default_access, assigned_to: nil }

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@shop)
  end

  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Shop.my(current_user).find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@shop)
  end

  def create
    respond_with(@shop) do |_format|
      if @shop.save
        @shops = get_shops
      end
    end
  end

  def update
    respond_with(@shop) do |_format|
      @shop.access = params[:shop][:access] if params[:shop][:access]
      @shop.update_attributes(resource_params)
    end
  end

  def destroy
    @shop.destroy

    respond_with(@shop) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  def redraw
    current_user.pref[:shops_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:shops_sort_by]  = Shop.sort_by_map[params[:sort_by]] if params[:sort_by]
    @shops = get_shops(page: 1, per_page: params[:per_page])
    set_options # Refresh options

    respond_with(@shops) do |format|
      format.js { render :index }
    end
  end

  private

  alias get_shops get_list_of_records

  def respond_to_destroy(method)
    if method == :ajax
      @shops = get_shops
      if @shops.empty?
        @shops = get_shops(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @shop.name)
      redirect_to shops_path
    end
  end
end
