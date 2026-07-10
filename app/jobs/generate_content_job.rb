class GenerateContentJob < ApplicationJob
  queue_as :default

  def perform(episode)
    data = Ai::ContentGenerator.new(episode).call
    episode.update!(
      name: data["name"].presence || episode.name,
      title: data["title"].presence || episode.title,
      kind: data["kind"].presence || episode.kind,
      movie_url: data["movie_url"].presence || episode.movie_url,
      audiobook_url: data["audiobook_url"].presence || episode.audiobook_url,
      transcript: data["transcript"].presence || episode.transcript
    )
  end
end
