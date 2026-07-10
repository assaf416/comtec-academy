require "tempfile"

module Tts
  # Generates placeholder Hebrew "podcast" audio locally with ffmpeg: a soft tone
  # whose length scales with the transcript, so the media pipeline is fully
  # exercised without calling a paid TTS service.
  class Stub
    def synthesize(text, **_opts)
      seconds = duration_for(text)
      file = Tempfile.new(["podcast", ".mp3"])
      Media::Ffmpeg.run("-f", "lavfi", "-i", "sine=frequency=196:duration=#{seconds}",
                        "-af", "afade=t=in:d=0.5,afade=t=out:st=#{seconds - 0.5}:d=0.5",
                        "-q:a", "9", file.path)
      file.path
    end

    private
      def duration_for(text)
        words = text.to_s.split.size
        [[words / 2.5, 3].max, 30].min.round(1) # ~2.5 words/sec, clamped 3..30s
      end
  end
end
