module Admin
  class QuizQuestionsController < BaseController
    before_action :set_episode

    def create
      question = @episode.quiz_questions.new(prompt: params.dig(:quiz_question, :prompt),
                                             correct_choice: params.dig(:quiz_question, :correct_choice))
      question.choices = split_choices(params.dig(:quiz_question, :choices))
      question.save
      redirect_to edit_admin_course_episode_path(@course, @episode), notice: t("admin.quiz.added")
    end

    def destroy
      @episode.quiz_questions.find(params[:id]).destroy
      redirect_to edit_admin_course_episode_path(@course, @episode), notice: t("admin.quiz.deleted"), status: :see_other
    end

    private
      def set_episode
        @course = Course.find(params[:course_id])
        @episode = @course.episodes.find(params[:episode_id])
      end

      # Choices come in as one-per-line text; blank => free-text question.
      def split_choices(raw)
        raw.to_s.split("\n").map(&:strip).reject(&:blank?)
      end
  end
end
