module Presentations
  # Parses a markdown screenplay into slides. Slides are separated by lines that
  # are exactly `---` (ignored inside fenced code blocks). Per-slide narration is
  # an HTML comment `<!-- note: ... -->`; the rest is the displayed content.
  class ScreenplayParser
    NOTE_RE   = /<!--\s*note:\s*(.*?)-->/mi
    LAYOUT_RE = /<!--\s*layout:\s*([\w-]+)\s*-->/i
    QUIZ_RE   = /<!--\s*quiz\b(.*?)-->/mi

    def self.parse(md)
      new.parse(md)
    end

    def parse(md)
      chunks(md.to_s).map do |chunk|
        quiz = extract_quiz(chunk)
        {
          content: chunk.gsub(NOTE_RE, "").gsub(LAYOUT_RE, "").gsub(QUIZ_RE, "").strip,
          notes: chunk[NOTE_RE, 1].to_s.strip,
          layout_key: chunk[LAYOUT_RE, 1]&.strip,
          choices: quiz[:choices],
          correct: quiz[:correct]
        }
      end.reject { |s| s[:content].blank? && s[:notes].blank? && s[:choices].blank? }
    end

    private
      # A `<!-- quiz ... -->` block: `- choice` lines are options, `answer: X` is correct.
      def extract_quiz(chunk)
        body = chunk[QUIZ_RE, 1]
        return { choices: [], correct: nil } if body.nil?

        {
          choices: body.scan(/^\s*[-*]\s+(.+)$/).flatten.map(&:strip),
          correct: body[/answer:\s*(.+)/i, 1]&.strip
        }
      end

      def chunks(md)
        slides = []
        current = []
        in_fence = false
        md.each_line do |line|
          in_fence = !in_fence if line.lstrip.start_with?("```")
          if !in_fence && line.strip == "---"
            slides << current.join
            current = []
          else
            current << line
          end
        end
        slides << current.join
        slides.map(&:strip).reject(&:blank?)
      end
  end
end
