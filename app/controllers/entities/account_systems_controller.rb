# frozen_string_literal: true

class AccountSystemsController < EntitiesController
  def new
    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.find_by_id(id)
        @account_system.account = instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) && return
      end
    end

    respond_with(@account_system)
  end

  def create
    respond_with(@account_system) do
      @account_system.save
    end
  end

  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = AccountSystem.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@account_system)
  end

  def update
    respond_with(@account_system) do
      @account_system.update_and_handle_types(system_params)
    end
  end

  def destroy
    @account_system.destroy
    respond_with(@account_system)
  end

  private

  def system_params
    params.require(:account_system).permit(:account_id, :system_id, :is_api_required, :expiration_date, :satisfaction)
  end
end
