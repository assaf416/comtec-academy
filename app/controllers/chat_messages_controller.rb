class ChatMessagesController < ApplicationController
  def create
    @course = Course.published.find(params[:course_id])
    @episode = @course.episodes.find(params[:episode_id])

    @message = @episode.chat_messages.create!(user: current_user, role: :user, body: params[:body])
    Activity.track(current_user, "chat_message", subject: @episode)

    reply_body = Ai::Assistant.new(@episode).answer(@message.body)
    @reply = @episode.chat_messages.create!(user: current_user, role: :assistant, body: reply_body)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to course_episode_path(@course, @episode) }
    end
  end
end
