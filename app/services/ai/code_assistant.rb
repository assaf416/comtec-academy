module Ai
  # Answers an engineer's question about a piece of code (a snippet today;
  # document/project later — the accessors are subject-agnostic). Retrieves
  # related code across projects (Ai::CodeRetriever), grounds the local LLM in
  # both the open code and the retrieved sources, and cites those sources.
  class CodeAssistant
    # Sources retrieved for the most recent #answer call.
    attr_reader :sources

    def initialize(subject)
      @subject = subject
      @sources = []
    end

    def answer(question)
      @sources = Ai::CodeRetriever.new.search("#{question} #{subject_title}", exclude: @subject)
      reply = generate(question)
      reply = "#{reply}\n\n#{sources_footer}" if @sources.present?
      reply
    end

    private
      def generate(question)
        if LocalClient.configured?
          reply = LocalClient.default.chat(question, system: system_prompt)
          reply.presence || stub_answer(question)
        else
          stub_answer(question)
        end
      rescue => e
        Rails.logger.warn("Ai::CodeAssistant local LLM failed, using stub: #{e.message}")
        stub_answer(question)
      end

      def sources_footer
        I18n.t("code_chat.sources") + ": " + @sources.map { |s| source_title(s) }.join(", ")
      end

      def system_prompt
        prompt = "אתה עוזר לחקירת קוד עבור מהנדסי Comtec. ענה על שאלת המהנדס על סמך הקוד הבא.\n\n" \
                 "קטע קוד \"#{subject_title}\" (#{code_language}):\n```#{code_language}\n#{code_body}\n```"
        unless @sources.blank?
          extras = @sources.map { |s| "\"#{source_title(s)}\":\n```\n#{source_body(s)}\n```" }.join("\n\n")
          prompt += "\n\nקוד קשור ממאגר Comtec:\n#{extras}"
        end
        prompt
      end

      def stub_answer(_question)
        preview = code_body.to_s.strip[0, 160]
        "על סמך הקוד ב\"#{subject_title}\" (#{code_language}): #{preview}…"
      end

      # --- subject-agnostic accessors (snippet/document/project) ---
      def subject_title
        @subject.try(:title).presence || @subject.try(:name).presence || @subject.try(:display_title).to_s
      end

      def code_language
        @subject.try(:language).presence || "text"
      end

      def code_body
        @subject.try(:body) || @subject.try(:content).to_s
      end

      def source_title(source)
        source.try(:title).presence || source.try(:display_title).presence || source.try(:name).to_s
      end

      def source_body(source)
        (source.try(:body) || source.try(:content)).to_s[0, 2000]
      end
  end
end
