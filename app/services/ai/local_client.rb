require "net/http"
require "json"

module Ai
  # HTTP client for a local, self-hosted LLM. Ollama-compatible by default, with
  # an OpenAI-compatible mode. Used so proprietary code (COBOL/AS400, C#, web)
  # never leaves Comtec's network.
  #
  # Configured entirely via ENV (the concrete endpoint/model is decided later):
  #   LOCAL_LLM_URL   - base URL (default http://localhost:11434)
  #   LOCAL_LLM_MODEL - model name (default "llama3")
  #   LOCAL_LLM_API   - "ollama" (default) or "openai"
  class LocalClient
    DEFAULT_URL = "http://localhost:11434".freeze
    DEFAULT_MODEL = "llama3".freeze

    class << self
      # Local mode is active only when an endpoint is explicitly configured, so
      # an unconfigured app falls back to the stub rather than a dead localhost.
      def configured?
        ENV["LOCAL_LLM_URL"].present?
      end

      def default
        new(base_url: ENV["LOCAL_LLM_URL"].presence || DEFAULT_URL,
            model:    ENV["LOCAL_LLM_MODEL"].presence || DEFAULT_MODEL,
            api:      ENV["LOCAL_LLM_API"].presence || "ollama")
      end
    end

    def initialize(base_url:, model:, api: "ollama")
      @base_url = base_url.to_s.chomp("/")
      @model = model
      @api = api
    end

    # Returns the model's reply text. `system` is optional grounding context.
    def chat(prompt, system: nil, timeout: 60)
      @api == "openai" ? chat_openai(prompt, system, timeout) : chat_ollama(prompt, system, timeout)
    end

    private
      def chat_ollama(prompt, system, timeout)
        body = post("/api/chat", { model: @model, messages: messages(prompt, system), stream: false }, timeout)
        body.dig("message", "content").to_s
      end

      def chat_openai(prompt, system, timeout)
        body = post("/v1/chat/completions", { model: @model, messages: messages(prompt, system), stream: false }, timeout)
        body.dig("choices", 0, "message", "content").to_s
      end

      def messages(prompt, system)
        msgs = []
        msgs << { role: "system", content: system } if system.present?
        msgs << { role: "user", content: prompt }
        msgs
      end

      def post(path, payload, timeout)
        uri = URI("#{@base_url}#{path}")
        req = Net::HTTP::Post.new(uri)
        req["content-type"] = "application/json"
        req.body = payload.to_json
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                              open_timeout: timeout, read_timeout: timeout) { |http| http.request(req) }
        JSON.parse(res.body)
      end
  end
end
