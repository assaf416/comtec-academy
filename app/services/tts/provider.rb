module Tts
  # Picks the active TTS backend. ElevenLabs when a key is configured, otherwise
  # a local ffmpeg stub so the pipeline runs end-to-end without any credentials.
  module Provider
    def self.current
      if ENV["ELEVENLABS_API_KEY"].present?
        Tts::ElevenLabs.new
      else
        Tts::Stub.new
      end
    end
  end
end
