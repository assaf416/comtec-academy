class EpisodesController < ApplicationController
  def show
    @course = Course.published.find(params[:course_id])
    @episode = @course.episodes.find(params[:id])
    @quiz_question = @episode.quiz_questions.first if @episode.quiz?
    @existing_answer = @quiz_question&.answer_for(current_user)
    @chat_messages = @episode.chat_messages.where(user: current_user).chronological
    @markdown_docs = @episode.markdown_docs.order(:name)

    Activity.track(current_user, "viewed_episode", subject: @episode,
                   course: @course.name, episode: @episode.display_title)
  end
end
