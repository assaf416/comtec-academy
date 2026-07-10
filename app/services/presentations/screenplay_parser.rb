module Presentations
  # Parses a markdown screenplay into slides. Slides are separated by lines that
  # are exactly `---` (ignored inside fenced code blocks). Per-slide narration is
  # an HTML comment `<!-- note: ... -->`; the rest is the displayed content.
  class ScreenplayParser
    NOTE_RE = /<!--\s*note:\s*(.*?)-->/mi

    def self.parse(md)
      new.parse(md)
    end

    def parse(md)
      chunks(md.to_s).map do |chunk|
        note = chunk[NOTE_RE, 1]
        { content: chunk.gsub(NOTE_RE, "").strip, notes: note.to_s.strip }
      end.reject { |s| s[:content].blank? && s[:notes].blank? }
    end

    private
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
