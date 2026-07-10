class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      unless user.active?
        redirect_to new_session_path, alert: t("auth.not_activated") and return
      end
      start_new_session_for user
      Activity.track(user, "signed_in")
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t("auth.bad_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
