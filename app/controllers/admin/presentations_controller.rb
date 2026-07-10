module Admin
  class PresentationsController < BaseController
    before_action :set_presentation,
                  only: %i[show edit update destroy generate_audio export_pdf export_movie publish]

    def index
      @presentations = Presentation.order(updated_at: :desc)
    end

    def show
      @slides = @presentation.slides.ordered
    end

    def new
      @presentation = Presentation.new
    end

    def create
      @presentation = Presentation.new(presentation_params)
      if @presentation.save
        @presentation.sync_slides!
        redirect_to admin_presentation_path(@presentation), notice: t("admin.presentations.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @presentation.update(presentation_params)
        @presentation.sync_slides!
        redirect_to admin_presentation_path(@presentation), notice: t("admin.presentations.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @presentation.destroy
      redirect_to admin_presentations_path, notice: t("admin.presentations.deleted"), status: :see_other
    end

    def generate_audio
      GeneratePresentationAudioJob.perform_later(@presentation)
      back t("admin.presentations.generating_audio")
    end

    def export_pdf
      ExportPresentationPdfJob.perform_later(@presentation)
      back t("admin.presentations.exporting_pdf")
    end

    def export_movie
      ExportPresentationMovieJob.perform_later(@presentation)
      back t("admin.presentations.exporting_movie")
    end

    # Toggle between draft and ready (ready presentations show in the viewer).
    def publish
      @presentation.update!(status: @presentation.ready? ? :draft : :ready)
      back t("admin.presentations.#{@presentation.ready? ? 'published' : 'unpublished'}")
    end

    private
      def set_presentation
        @presentation = Presentation.find(params[:id])
      end

      def presentation_params
        params.require(:presentation).permit(:title, :description, :source_md, :background_music)
      end

      def back(notice)
        redirect_to admin_presentation_path(@presentation), notice: notice
      end
  end
end
