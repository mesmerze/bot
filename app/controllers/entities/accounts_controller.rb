# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class AccountsController < EntitiesController
  before_action :get_data_for_sidebar, only: :index
  before_action :set_orgs, only: %i[new edit create]
  before_action :set_shops, only: %i[new edit create]

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    @accounts = get_accounts(page: page_param, per_page: per_page_param)

    respond_with @accounts do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @accounts }
    end
  end

  # GET /accounts/1
  # AJAX /accounts/1
  #----------------------------------------------------------------------------
  def show
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new
    @timeline = timeline(@account)
    respond_with(@account)
  end

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @org = Org.new(user: current_user)
    @account.attributes = { user: current_user, access: Setting.default_access, assigned_to: nil }

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@account)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @org = @account.org || Org.new(user: current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Account.my(current_user).find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@account)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@account) do |_format|
      if @account.save_with_org_and_opportunity(params.permit!)
        @account.add_comment_by_user(@comment_body, current_user)
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @accounts = get_accounts
        get_data_for_sidebar
      else
        @orgs = Org.order('name')
        @org = if params[:org][:id].blank?
                 if request.referer =~ %r{ \/accounts\/(\d+)\z }
                   Org.find(Regexp.last_match[1]) # related
                 else
                   Org.new(user: current_user)
                 end
               else
                 Org.find(params[:org][:id])
               end
      end
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@account) do |_format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @account.access = params[:account][:access] if params[:account][:access]
      if @account.update_with_org(params.permit!)
        get_data_for_sidebar
      else
        @orgs = Org.order('name')
        @org = if @account.org
                 Org.find(@account.org.id)
               else
                 Org.new(user: current_user)
               end
      end
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @account.destroy

    respond_with(@account) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  def lead
    @account = Account.find(params[:id])
    respond_to do |format|
      format.js { render partial: 'lead' }
    end
  end

  # PUT /accounts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # PUT /accounts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /accounts/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:accounts_per_page] = per_page_param if per_page_param
    current_user.pref[:accounts_sort_by]  = Account.sort_by_map[params[:sort_by]] if params[:sort_by]
    @accounts = get_accounts(page: 1, per_page: per_page_param)
    set_options # Refresh options

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:accounts_filter] = params[:category]
    @accounts = get_accounts(page: 1, per_page: per_page_param)

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

  private

  def set_orgs
    @orgs = Org.order('name')
  end

  def set_shops
    @shops = Shop.my(current_user).order('name')
  end

  #----------------------------------------------------------------------------
  alias get_accounts get_list_of_records

  #----------------------------------------------------------------------------
  def list_includes
    %i[pipeline_opportunities user tags shops].freeze
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @accounts = get_accounts
      get_data_for_sidebar
      if @accounts.empty?
        @accounts = get_accounts(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
      # At this point render default destroy.js
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @account.name)
      redirect_to accounts_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @account_category_total = HashWithIndifferentAccess[
                              Setting.account_category.map do |key|
                                [key, Account.my(current_user).where(category: key.to_s).count]
                              end
    ]
    categorized = @account_category_total.values.sum
    @account_category_total[:all] = Account.my(current_user).count
    @account_category_total[:other] = @account_category_total[:all] - categorized
  end
end
