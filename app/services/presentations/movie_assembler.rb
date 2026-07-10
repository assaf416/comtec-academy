require "open3"
require "tmpdir"

module Presentations
  # Assembles a narrated MP4 from a presentation: render the deck to PDF (Chrome),
  # rasterize each page to a PNG (pdftoppm), build a per-slide video segment timed
  # to its voice-over, concat them, mix background music, and burn captions.
  class MovieAssembler
    def initialize(presentation)
      @presentation = presentation
    end

    def call
      slides = @presentation.slides.ordered.to_a
      return false if slides.empty? || !Media::Chrome.available?

      Dir.mktmpdir("pres-movie") do |dir|
        pngs = render_slide_pngs(dir)
        return false if pngs.empty?

        segments = slides.each_with_index.filter_map do |slide, i|
          next unless pngs[i]

          build_segment(dir, i, pngs[i], slide)
        end
        return false if segments.empty?

        video = concat(dir, segments)
        video = mix_music(dir, video) if @presentation.background_music.attached?
        video = burn_captions(dir, video, slides)

        File.open(video) do |f|
          @presentation.movie.attach(io: f, filename: "presentation-#{@presentation.id}.mp4", content_type: "video/mp4")
        end
      end
      true
    end

    private
      def render_slide_pngs(dir)
        html = File.join(dir, "deck.html")
        File.write(html, SlideRenderer.new.deck_html(@presentation))
        pdf = File.join(dir, "deck.pdf")
        Media::Chrome.to_pdf(html, pdf)

        _, status = Open3.capture2e("pdftoppm", "-png", "-r", "96", pdf, File.join(dir, "slide"))
        raise "pdftoppm failed" unless status.success?

        Dir.glob(File.join(dir, "slide-*.png")).sort_by { |f| f[/(\d+)\.png\z/, 1].to_i }
      end

      def build_segment(dir, index, png, slide)
        seg = File.join(dir, "seg-#{index}.mp4")
        duration = slide.effective_duration.round(2)
        common = [ "-c:v", "libx264", "-t", duration, "-pix_fmt", "yuv420p",
                   "-vf", "scale=1280:720", "-r", "25", "-c:a", "aac", "-shortest", seg ]
        if slide.audio.attached?
          audio = File.join(dir, "a-#{index}.wav")
          File.binwrite(audio, slide.audio.download)
          Media::Ffmpeg.run("-loop", "1", "-i", png, "-i", audio, *common)
        else
          Media::Ffmpeg.run("-loop", "1", "-i", png,
                            "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo", *common)
        end
        seg
      end

      def concat(dir, segments)
        list = File.join(dir, "segments.txt")
        File.write(list, segments.map { |s| "file '#{s}'" }.join("\n"))
        out = File.join(dir, "concat.mp4")
        Media::Ffmpeg.run("-f", "concat", "-safe", "0", "-i", list, "-c", "copy", out)
        out
      end

      def mix_music(dir, video)
        music = File.join(dir, "music-src")
        File.binwrite(music, @presentation.background_music.download)
        out = File.join(dir, "with-music.mp4")
        Media::Ffmpeg.run("-i", video, "-i", music, "-filter_complex",
          "[1:a]volume=0.15,afade=t=in:d=1[bg];[0:a][bg]amix=inputs=2:duration=first[a]",
          "-map", "0:v", "-map", "[a]", "-c:v", "copy", "-c:a", "aac", out)
        out
      end

      def burn_captions(dir, video, slides)
        srt = write_srt(dir, slides)
        return video unless srt

        out = File.join(dir, "captioned.mp4")
        Media::Ffmpeg.run("-i", video,
          "-vf", "subtitles=#{srt}:force_style='Fontsize=18,Alignment=2,BorderStyle=3,Outline=1'",
          "-c:a", "copy", out)
        out
      end

      def write_srt(dir, slides)
        path = File.join(dir, "captions.srt")
        t = 0.0
        entries = []
        slides.each_with_index do |slide, i|
          dur = slide.effective_duration
          if slide.notes.present?
            entries << "#{i + 1}\n#{ts(t)} --> #{ts(t + dur)}\n#{slide.notes.strip}\n"
          end
          t += dur
        end
        return nil if entries.empty?

        File.write(path, entries.join("\n"))
        path
      end

      def ts(seconds)
        ms = (seconds * 1000).round
        format("%02d:%02d:%02d,%03d", ms / 3_600_000, (ms / 60_000) % 60, (ms / 1000) % 60, ms % 1000)
      end
  end
end
