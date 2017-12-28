class OrgsController < EntitiesController
  before_action :set_account, only: %i[new create]

  def index
    @orgs = get_orgs(page: params[:page])

    respond_with @orgs
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

  def create
    @comment_body = params[:comment_body]

    respond_with(@org) do |_format|
      if @org.save
        @org.add_comment_by_user(@comment_body, current_user)
        @orgs = get_orgs
      end
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

  alias get_orgs get_list_of_records

  def set_account
    @accs = Account.my.order('name')
  end
end
