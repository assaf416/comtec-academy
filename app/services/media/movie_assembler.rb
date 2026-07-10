require "tmpdir"

module Media
  # Assembles an episode movie with ffmpeg from a thumbnail/slide + narration
  # audio, with an animated Ken Burns intro (the pizzazz ✨), optional burned-in
  # captions from the transcript, and an optional soft background-music bed.
  class MovieAssembler
    def initialize(episode, music: false, music_volume: 0.15, captions: true)
      @episode = episode
      @music = music
      @music_volume = music_volume.to_f.clamp(0.0, 1.0)
      @music_volume = 0.15 if @music_volume.zero?
      @captions = captions
    end

    # Returns true on success, false if there's nothing to assemble.
    def call
      Dir.mktmpdir("assemble") do |dir|
        image = thumbnail_path(dir)
        audio = audio_path(dir)
        return false unless audio

        duration = [Media::Ffmpeg.duration(audio), 1.0].max
        srt = (@captions ? CaptionBuilder.new(@episode.transcript, duration).write_to(File.join(dir, "cap.srt")) : nil)
        music = music_path(dir, duration) if @music
        out = File.join(dir, "movie.mp4")

        Media::Ffmpeg.run(*ffmpeg_args(image:, audio:, srt:, music:, duration:, out:))
        attach(out)
        true
      end
    end

    private
      def ffmpeg_args(image:, audio:, srt:, music:, duration:, out:)
        args = ["-loop", "1", "-t", duration.round(2), "-i", image, "-i", audio]
        args += ["-i", music] if music
        args += ["-filter_complex", filtergraph(srt:, music:),
                 "-map", "[v]", "-map", "[aout]", "-shortest", "-r", "25",
                 "-c:v", "libx264", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "128k",
                 "-movflags", "+faststart", out]
        args
      end

      def filtergraph(srt:, music:)
        video = "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720," \
                "zoompan=z='min(zoom+0.0006,1.15)':d=1:s=1280x720:fps=25," \
                "fade=t=in:d=1,format=yuv420p"
        video += ",subtitles=#{srt}:force_style='Fontsize=20,Alignment=2,BorderStyle=3,Outline=1'" if srt
        video += "[v]"

        audio =
          if music
            "[2:a]volume=#{@music_volume},afade=t=in:d=1.5[bg];" \
            "[1:a]afade=t=in:d=0.3[narr];" \
            "[narr][bg]amix=inputs=2:duration=first:dropout_transition=0[aout]"
          else
            "[1:a]afade=t=in:d=0.3[aout]"
          end

        "#{video};#{audio}"
      end

      # Use the attached thumbnail if present, otherwise generate a title card.
      def thumbnail_path(dir)
        path = File.join(dir, "thumb.png")
        if @episode.thumbnail.attached?
          File.binwrite(path, @episode.thumbnail.download)
          path
        else
          ThumbnailGenerator.new(@episode).generate_to(path)
        end
      end

      # Use attached audio, otherwise synthesize a Hebrew podcast from the transcript.
      def audio_path(dir)
        path = File.join(dir, "audio.mp3")
        if @episode.audio.attached?
          File.binwrite(path, @episode.audio.download)
          path
        elsif @episode.transcript.present?
          src = Tts::Provider.current.synthesize(@episode.transcript)
          FileUtils.cp(src, path)
          path
        end
      end

      def music_path(dir, duration)
        path = File.join(dir, "music.mp3")
        Media::Ffmpeg.run("-f", "lavfi", "-i", "sine=frequency=130.81:duration=#{duration.round(2)}",
                          "-q:a", "9", path)
        path
      end

      def attach(out)
        File.open(out) do |file|
          @episode.movie.attach(io: file, filename: "episode-#{@episode.id}-movie.mp4", content_type: "video/mp4")
        end
      end
  end
end
