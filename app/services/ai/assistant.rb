module Ai
  # Answers a learner's question about an episode. Ships as a stub that echoes
  # a transcript-grounded reply; swap `generate` for a real Claude call once
  # ANTHROPIC_API_KEY is set (see Ai::ContentGenerator for the HTTP pattern).
  class Assistant
    def initialize(episode)
      @episode = episode
    end

    def answer(question)
      if ENV["ANTHROPIC_API_KEY"].present?
        # Real implementation lands with S14's Claude client.
        stub_answer(question)
      else
        stub_answer(question)
      end
    end

    private
      def stub_answer(question)
        snippet = @episode.transcript.to_s.strip[0, 240]
        if snippet.present?
          "שאלה טובה על \"#{@episode.display_title}\". על סמך תוכן הפרק: #{snippet}…"
        else
          "תודה על השאלה! צוות הקורס יחזור אליך עם תשובה מפורטת בקרוב."
        end
      end
  end
end
