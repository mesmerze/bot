# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @auth = request.env["omniauth.auth"]
    @user = User.find_for_google_oauth2(@auth)

    if @user
      revoke_token && return if @user.refresh_token.blank?
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = t('devise.omniauth_callbacks.success', kind: 'Google')
    else
      process_new_user
    end
  end

  private

  def process_new_user
    @user = User.new(email: @auth.info.email,
                     username: @auth.info.email,
                     first_name: @auth.info.first_name,
                     last_name: @auth.info.last_name,
                     password: Devise.friendly_token[0, 20],
                     confirmed_at: Time.current,
                     oauth_token: @auth.credentials.token,
                     refresh_token: @auth.credentials.refresh_token)
    revoke_token && return if @user.refresh_token.blank?
    if @user.save
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = t('devise.omniauth_callbacks.success', kind: 'Google')
    else
      process_errors
    end
  end

  def process_errors
    flash[:warning] = @user.errors[:email] ? @user.errors[:email]&.first : t(:try_again_later)
    redirect_to new_user_session_path
  end

  def revoke_token
    uri = URI('https://accounts.google.com/o/oauth2/revoke')
    params = { token: @user.oauth_token }
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get(uri)
    flash[:notice] = t :access_needed
    redirect_to new_user_session_path
  end
end
