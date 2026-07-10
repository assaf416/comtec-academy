class GenerateAudioJob < ApplicationJob
  queue_as :default

  # Produce a Hebrew podcast from the transcript and attach it to the episode.
  def perform(episode)
    text = episode.transcript.presence || episode.display_title
    path = Tts::Provider.current.synthesize(text)

    File.open(path) do |file|
      episode.audio.attach(io: file, filename: "episode-#{episode.id}-podcast.mp3", content_type: "audio/mpeg")
    end
    episode.update!(audiobook_url: Rails.application.routes.url_helpers.rails_blob_path(episode.audio, only_path: true))
  ensure
    File.delete(path) if path && File.exist?(path)
  end
end
