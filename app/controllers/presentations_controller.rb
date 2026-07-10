class PresentationsController < ApplicationController
  # Viewer for all signed-in users; only published (ready) presentations.
  def index
    @presentations = Presentation.ready.order(updated_at: :desc)
  end

  def show
    @presentation = Presentation.ready.find(params[:id])
    @slides = @presentation.slides.ordered
  rescue ActiveRecord::RecordNotFound
    redirect_to presentations_path, alert: t("presentations.empty")
  end
end
