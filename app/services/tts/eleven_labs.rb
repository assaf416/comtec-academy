require "net/http"
require "json"
require "tempfile"

module Tts
  # Real Hebrew TTS via ElevenLabs. Requires ELEVENLABS_API_KEY; the voice can be
  # overridden with ELEVENLABS_VOICE_ID (defaults to a multilingual voice).
  class ElevenLabs
    DEFAULT_VOICE = ENV.fetch("ELEVENLABS_VOICE_ID", "21m00Tcm4TlvDq8ikWAM")
    MODEL = "eleven_multilingual_v2"

    def synthesize(text, voice: DEFAULT_VOICE, **_opts)
      uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{voice}")
      req = Net::HTTP::Post.new(uri)
      req["xi-api-key"] = ENV.fetch("ELEVENLABS_API_KEY")
      req["content-type"] = "application/json"
      req["accept"] = "audio/mpeg"
      req.body = { text: text, model_id: MODEL,
                   voice_settings: { stability: 0.5, similarity_boost: 0.75 } }.to_json

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
      raise "ElevenLabs error #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)

      file = Tempfile.new(["podcast", ".mp3"])
      file.binmode
      file.write(res.body)
      file.flush
      file.path
    end
  end
end
