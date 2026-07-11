module Ai
  # Answers a learner's question about an episode. Routes to a local, self-hosted
  # LLM when one is configured (Ai::LocalClient), otherwise falls back to a
  # transcript-grounded stub. Never raises into the request path.
  class Assistant
    def initialize(episode)
      @episode = episode
    end

    def answer(question)
      if LocalClient.configured?
        reply = LocalClient.default.chat(question, system: system_prompt)
        reply.presence || stub_answer(question)
      else
        stub_answer(question)
      end
    rescue => e
      Rails.logger.warn("Ai::Assistant local LLM failed, using stub: #{e.message}")
      stub_answer(question)
    end

    private
      def system_prompt
        transcript = @episode.transcript.to_s.strip
        "אתה עוזר לומד. ענה בעברית על שאלת הלומד על סמך תוכן הפרק \"#{@episode.display_title}\".\n\n" \
          "תוכן הפרק:\n#{transcript}"
      end

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
