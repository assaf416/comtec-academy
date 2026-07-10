module Admin
  class EpisodesController < BaseController
    before_action :set_course
    before_action :set_episode, only: %i[show edit update destroy
                                         generate_content generate_audio
                                         generate_thumbnail assemble_movie]

    def new
      @episode = @course.episodes.new
    end

    def create
      @episode = @course.episodes.new(episode_params)
      if @episode.save
        redirect_to edit_admin_course_episode_path(@course, @episode), notice: t("admin.episodes.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      redirect_to edit_admin_course_episode_path(@course, @episode)
    end

    def edit
    end

    def update
      if @episode.update(episode_params)
        redirect_to edit_admin_course_episode_path(@course, @episode), notice: t("admin.episodes.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @episode.destroy
      redirect_to admin_course_path(@course), notice: t("admin.episodes.deleted"), status: :see_other
    end

    # --- Media actions (jobs defined in Phases 7-8) ---
    def generate_content
      GenerateContentJob.perform_later(@episode)
      redirect_back_to_episode t("admin.episodes.generating_content")
    end

    def generate_audio
      GenerateAudioJob.perform_later(@episode)
      redirect_back_to_episode t("admin.episodes.generating_audio")
    end

    def generate_thumbnail
      GenerateThumbnailJob.perform_later(@episode)
      redirect_back_to_episode t("admin.studio.generating_thumbnail")
    end

    def assemble_movie
      AssembleMovieJob.perform_later(@episode,
        music: params[:background_music] == "1",
        music_volume: (params[:music_volume].presence || 0.15).to_f,
        captions: params[:captions] == "1")
      redirect_back_to_episode t("admin.studio.assembling")
    end

    private
      def set_course
        @course = Course.find(params[:course_id])
      end

      def set_episode
        @episode = @course.episodes.find(params[:id])
      end

      def episode_params
        params.require(:episode).permit(:name, :title, :kind, :position, :transcript,
                                        :movie_url, :audiobook_url, :movie, :audio, :thumbnail)
      end

      def redirect_back_to_episode(notice)
        redirect_to edit_admin_course_episode_path(@course, @episode), notice: notice
      end
  end
end
