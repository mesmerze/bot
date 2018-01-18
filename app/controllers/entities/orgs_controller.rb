# frozen_string_literal: true

class OrgsController < EntitiesController
  before_action :set_account, only: %i[new edit create]

  def index
    @orgs = get_orgs(page: params[:page])

    respond_with @orgs
  end

  def show
    @comment = Comment.new
    @timeline = timeline(@org)
    respond_with(@org)
  end

  def new
    @org.attributes = { user: current_user, access: Setting.default_access, assigned_to: nil }
    @org.accounts.build

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@org)
  end

  def edit
    @accounts = @org.accounts

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Org.my(current_user).find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@org)
  end

  def create
    @comment_body = params[:comment_body]

    respond_with(@org) do |_format|
      if @org.save
        @org.add_comment_by_user(@comment_body, current_user)
        @org = Org.find(@org.id)
        @orgs = get_orgs
      end
    end
  end

  def update
    @comment_body = params[:comment_body]

    respond_with(@org) do |_format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @org.add_comment_by_user(@comment_body, current_user)
      @org.access = params[:org][:access] if params[:org][:access]
      @org.update_attributes(resource_params)
    end
  end

  def destroy
    @org.destroy

    respond_with(@org) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  def redraw
    current_user.pref[:orgs_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:orgs_sort_by]  = Org.sort_by_map[params[:sort_by]] if params[:sort_by]
    @orgs = get_orgs(page: 1, per_page: params[:per_page])
    set_options # Refresh options

    respond_with(@orgs) do |format|
      format.js { render :index }
    end
  end

  private

  def order_by_attributes(scope, order)
    case order
    when 'orgs.revenue'
      scope.order("revenue DESC NULLS LAST")
    else
      scope.order(order)
    end
  end

  alias get_orgs get_list_of_records

  def list_includes
    [:tags, accounts: [:opportunities]]
  end

  def set_account
    @accs = Account.accessible(@org.id).my(current_user).order('name')
  end

  def respond_to_destroy(method)
    if method == :ajax
      @orgs = get_orgs
      if @orgs.empty?
        @orgs = get_orgs(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @org.name)
      redirect_to orgs_path
    end
  end
end
