require "tmpdir"

class GeneratePresentationAudioJob < ApplicationJob
  queue_as :default

  # Synthesize each slide's speaker notes to a wav voice-over and record its duration.
  def perform(presentation)
    presentation.slides.ordered.each do |slide|
      next if slide.notes.blank?

      generate_for(slide)
    end
    presentation.update!(status: :ready)
  end

  private
    def generate_for(slide)
      mp3 = Tts::Provider.current.synthesize(slide.notes)
      Dir.mktmpdir("slide-audio") do |dir|
        wav = File.join(dir, "slide-#{slide.id}.wav")
        Media::Ffmpeg.run("-i", mp3, wav)
        File.open(wav) do |f|
          slide.audio.attach(io: f, filename: "slide-#{slide.id}.wav", content_type: "audio/wav")
        end
        slide.update!(duration: Media::Ffmpeg.duration(wav))
      end
    ensure
      File.delete(mp3) if mp3 && File.exist?(mp3)
    end
end
