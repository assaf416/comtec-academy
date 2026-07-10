module Admin
  class StudiosController < BaseController
    def show
      @course = Course.find(params[:course_id])
      @episode = @course.episodes.find(params[:episode_id])
    end
  end
end
