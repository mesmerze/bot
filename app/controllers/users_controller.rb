# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class UsersController < ApplicationController
  before_action :set_current_tab, only: %i[show opportunities_overview] # Don't hightlight any tabs.
  before_action :set_sort_options, only: %i[opportunities_overview filter]

  check_authorization
  load_and_authorize_resource # handles all security

  respond_to :html, only: %i[show new]

  # GET /users/1
  # GET /users/1.js
  #----------------------------------------------------------------------------
  def show
    @user = current_user if params[:id].nil?
    respond_with(@user)
  end

  # GET /users/new
  # GET /users/new.js
  #----------------------------------------------------------------------------
  def new
    respond_with(@user)
  end

  # POST /users
  # POST /users.js
  #----------------------------------------------------------------------------
  def create
    if @user.save
      if Setting.user_signup == :needs_approval
        flash[:notice] = t(:msg_account_created)
        redirect_to login_url
      else
        flash[:notice] = t(:msg_successful_signup)
        redirect_back_or_default profile_url
      end
    else
      render :new
    end
  end

  # GET /users/1/edit.js
  #----------------------------------------------------------------------------
  def edit
    respond_with(@user)
  end

  # PUT /users/1
  # PUT /users/1.js
  #----------------------------------------------------------------------------
  def update
    @user.update_attributes(user_params)
    flash[:notice] = t(:msg_user_updated)
    respond_with(@user)
  end

  # GET /users/1/avatar
  # GET /users/1/avatar.js
  #----------------------------------------------------------------------------
  def avatar
    respond_with(@user)
  end

  # PUT /users/1/upload_avatar
  # PUT /users/1/upload_avatar.js
  #----------------------------------------------------------------------------
  def upload_avatar
    if params[:gravatar]
      @user.avatar = nil
      @user.save
      render
    else
      if params[:avatar]
        avatar = Avatar.create(avatar_params)
        if avatar.valid?
          @user.avatar = avatar
        else
          @user.avatar.errors.clear
          @user.avatar.errors.add(:image, t(:msg_bad_image_file))
        end
      end
      responds_to_parent do
        # Without return RSpec2 screams bloody murder about rendering twice:
        # within the block and after yield in responds_to_parent.
        render && (return if Rails.env.test?)
      end
    end
  end

  # GET /users/1/password
  # GET /users/1/password.js
  #----------------------------------------------------------------------------
  def password
    respond_with(@user)
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.js
  #----------------------------------------------------------------------------
  def change_password
    if @user.valid_password?(params[:current_password], true) || @user.password_hash.blank?
      if params[:user][:password].blank?
        flash[:notice] = t(:msg_password_not_changed)
      else
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        @user.save
        flash[:notice] = t(:msg_password_changed)
      end
    else
      @user.errors.add(:current_password, t(:msg_invalid_password))
    end

    respond_with(@user)
  end

  # GET /users/1/redraw
  #----------------------------------------------------------------------------
  def redraw
    current_user.preference[:locale] = params[:locale]
    render js: %(window.location.href = "#{user_path(current_user)}";)
  end

  # GET /users/opportunities_overview
  #----------------------------------------------------------------------------
  def opportunities_overview
    @groups = Group.all.order("name")
    @users_with_opportunities = User.joins(:groups)
                                    .where('groups.id IN (?)', @groups.ids)
                                    .have_assigned_opportunities.select('groups.id as group_id, groups.name as group_name')
                                    .order('groups.name, users.first_name').group_by(&:group_id)
    @unassigned_opportunities = Opportunity.my(current_user).unassigned.pipeline.order(:stage).includes(:account, :user, :tags)
  end

  def filter
    group_ids = params[:groups].split(',').map(&:to_i)
    user_ids =  params[:users].split(',').map(&:to_i)
    @users_with_opportunities = User.joins(:groups)
                                    .where('groups.id IN (?) AND users.id IN (?)', group_ids, user_ids)
                                    .have_assigned_opportunities.select('groups.id as group_id, groups.name as group_name')
                                    .order('groups.name, users.first_name').includes(:opportunities).group_by(&:group_id)
    @groups = Group.where(id: group_ids).order("name")
    respond_to do |format|
      format.js
    end
  end

  def shops
    @opportunity = Opportunity.find_by(id: params[:opportunity_id]) || Opportunity.new
    @shops = Shop.where(account_id: params[:account_id])
    @options = @shops.map { |a| [a.name, a.id] }
  end

  protected

  def set_sort_options
    @options_for_sort = Opportunity.sort_by_map.map { |k, v| [t("option_#{k}".to_sym), v] }
    @sort = params[:sort] || 'stage_sort ASC'
  end

  def user_params
    return {} unless params[:user]
    params[:user][:email].try(:strip!)
    params[:user].permit(
      :username,
      :email,
      :first_name,
      :last_name,
      :title,
      :company,
      :alt_email,
      :phone,
      :mobile,
      :aim,
      :yahoo,
      :google,
      :skype
    )
  end

  def avatar_params
    return {} unless params[:avatar]
    params[:avatar]
      .permit(:image)
      .merge(entity: @user)
  end
end
