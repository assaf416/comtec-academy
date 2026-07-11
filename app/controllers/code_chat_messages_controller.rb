class CodeChatMessagesController < ApplicationController
  def create
    @snippet = Snippet.find(params[:snippet_id])

    @message = @snippet.code_chat_messages.create!(user: current_user, role: :user, body: params[:body])
    Activity.track(current_user, "code_chat_message", subject: @snippet)

    reply_body = Ai::CodeAssistant.new(@snippet).answer(@message.body)
    @reply = @snippet.code_chat_messages.create!(user: current_user, role: :assistant, body: reply_body)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to snippet_path(@snippet) }
    end
  end
end
