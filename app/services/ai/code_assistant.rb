module Ai
  # Answers an engineer's question about a piece of code (a snippet today;
  # document/project later — the accessors are subject-agnostic). Routes to the
  # local LLM with the code as grounding context, falling back to a stub.
  class CodeAssistant
    def initialize(subject)
      @subject = subject
    end

    def answer(question)
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

    private
      def system_prompt
        "אתה עוזר לחקירת קוד עבור מהנדסי Comtec. ענה על שאלת המהנדס על סמך הקוד הבא בלבד.\n\n" \
          "קטע קוד \"#{subject_title}\" (#{code_language}):\n```#{code_language}\n#{code_body}\n```"
      end

      def stub_answer(_question)
        preview = code_body.to_s.strip[0, 160]
        "על סמך הקוד ב\"#{subject_title}\" (#{code_language}): #{preview}…"
      end

      # Subject-agnostic accessors — snippet has title/language/body; documents
      # and projects can expose the same shape later.
      def subject_title
        @subject.try(:title) || @subject.try(:name) || @subject.try(:display_title).to_s
      end

      def code_language
        @subject.try(:language).presence || "text"
      end

      def code_body
        @subject.try(:body) || @subject.try(:content).to_s
      end
  end
end
