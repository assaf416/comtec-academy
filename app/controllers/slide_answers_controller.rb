class SlideAnswersController < ApplicationController
  # Store (or update) the current user's answer to a quiz slide.
  def create
    @slide = Slide.find(params[:slide_id])
    @answer = current_user.slide_answers.find_or_initialize_by(slide: @slide)
    @answer.answer = params[:answer]
    @answer.save

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to presentation_path(@slide.presentation) }
    end
  end
end
