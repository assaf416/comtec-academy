class InvitationsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token

  # Show the "choose your password" activation form.
  def edit
  end

  # Set the password, activate the account and sign the user in.
  def update
    if @user.active?
      redirect_to new_session_path, alert: t("invitation.already_active") and return
    end

    if @user.activate!(password: params[:password], password_confirmation: params[:password_confirmation])
      start_new_session_for @user
      redirect_to root_path, notice: t("invitation.welcome", name: @user.display_name)
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_token_for!(:invitation, params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      redirect_to new_session_path, alert: t("invitation.invalid_link")
    end
end
