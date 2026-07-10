class CoursesController < ApplicationController
  def index
    @courses = Course.published.order(:name)
  end

  def show
    @course = Course.published.find(params[:id])
    @episodes = @course.episodes.ordered
  end
end
