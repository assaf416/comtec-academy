require "digest"

module Media
  # Generates a colorful gradient title card for an episode. Colours are derived
  # from the title so each episode gets a distinct, stable look; the big number
  # is the episode position (kept numeric to avoid RTL text-shaping issues).
  class ThumbnailGenerator
    FONT = [
      "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
      "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    ].find { |f| File.exist?(f) }

    def initialize(episode)
      @episode = episode
    end

    def generate_to(path)
      c0, c1 = palette
      source = "gradients=s=1280x720:c0=#{c0}:c1=#{c1}:x0=0:y0=0:x1=1280:y1=720:nb_colors=2"
      Media::Ffmpeg.run("-f", "lavfi", "-i", source, "-vf", "format=rgb24#{overlay}", "-frames:v", "1", path)
      path
    end

    private
      def overlay
        return "" unless FONT

        label = @episode.position.to_s
        ",drawtext=fontfile=#{FONT}:text='#{label}':fontcolor=white@0.9:fontsize=320:" \
          "x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.35:shadowx=6:shadowy=6"
      end

      def palette
        h = Digest::MD5.hexdigest(@episode.display_title.to_s + @episode.id.to_s)
        [ "0x#{h[0, 6]}", "0x#{h[6, 6]}" ]
      end
  end
end
