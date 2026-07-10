class SendInvitationJob < ApplicationJob
  queue_as :default

  def perform(user)
    InvitationMailer.invite(user).deliver_now
  end
end
