class AssembleMovieJob < ApplicationJob
  queue_as :default

  def perform(episode, music: false, music_volume: 0.15, captions: true)
    Media::MovieAssembler.new(episode, music: music, music_volume: music_volume, captions: captions).call
  end
end
