class QuizAnswersController < ApplicationController
  # Store (or update) the current user's answer to a quiz question for later use.
  def create
    question = QuizQuestion.find(params[:quiz_question_id])
    answer = QuizAnswer.find_or_initialize_by(user: current_user, quiz_question: question)
    answer.answer = params[:answer]
    answer.save

    episode = question.episode
    Activity.track(current_user, "answered_quiz", subject: episode, answer: answer.answer)
    redirect_to course_episode_path(episode.course, episode), notice: t("quiz.saved")
  end
end
