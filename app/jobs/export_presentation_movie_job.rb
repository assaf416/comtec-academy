class ExportPresentationMovieJob < ApplicationJob
  queue_as :default

  def perform(presentation)
    Presentations::MovieAssembler.new(presentation).call
  end
end
