require "tmpdir"

class GenerateThumbnailJob < ApplicationJob
  queue_as :default

  def perform(episode)
    Dir.mktmpdir("thumb") do |dir|
      path = File.join(dir, "thumb.png")
      Media::ThumbnailGenerator.new(episode).generate_to(path)
      File.open(path) do |file|
        episode.thumbnail.attach(io: file, filename: "episode-#{episode.id}-thumb.png", content_type: "image/png")
      end
    end
  end
end
