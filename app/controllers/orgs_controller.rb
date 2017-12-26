class OrgsController < EntitiesController
  def index
    @orgs = get_orgs(page: params[:page])

    respond_with @orgs
  end

  private

  alias get_orgs get_list_of_records
end
