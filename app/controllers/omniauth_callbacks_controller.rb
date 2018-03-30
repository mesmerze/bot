# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"])

    if @user
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = t('devise.omniauth_callbacks.success', kind: 'Google')
    else
      redirect_to new_user_session_path, notice: t(:cant_find_user) + ': ' + request.env['omniauth.auth'].info.email&.to_s
    end
  end
end
