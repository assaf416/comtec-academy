class InvitationMailer < ApplicationMailer
  def invite(user)
    @user = user
    @token = user.generate_token_for(:invitation)
    @url = accept_invitation_url(token: @token)
    mail subject: t("invitation.email_subject"), to: user.email_address
  end
end
