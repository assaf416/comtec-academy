module Admin
  class CoursesController < BaseController
    before_action :set_course, only: %i[show edit update destroy]

    def index
      @courses = Course.order(:name)
    end

    def show
      @episodes = @course.episodes.ordered
    end

    def new
      @course = Course.new
    end

    def create
      @course = Course.new(course_params)
      if @course.save
        redirect_to admin_course_path(@course), notice: t("admin.courses.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @course.update(course_params)
        redirect_to admin_course_path(@course), notice: t("admin.courses.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @course.destroy
      redirect_to admin_courses_path, notice: t("admin.courses.deleted"), status: :see_other
    end

    private
      def set_course
        @course = Course.find(params[:id])
      end

      def course_params
        params.require(:course).permit(:name, :details, :published, :image)
      end
  end
end
