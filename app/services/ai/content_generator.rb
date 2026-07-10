require "net/http"
require "json"

module Ai
  # Drafts episode content: name, kind, title, movie_url, audiobook_url, transcript.
  # Ships as a stub; if ANTHROPIC_API_KEY is set it calls Claude for real.
  class ContentGenerator
    MODEL = "claude-sonnet-5"
    API_URL = "https://api.anthropic.com/v1/messages"

    def initialize(episode)
      @episode = episode
      @course = episode.course
    end

    # Returns a Hash of episode attributes.
    def call
      ENV["ANTHROPIC_API_KEY"].present? ? generate_with_claude : stub
    rescue => e
      Rails.logger.warn("ContentGenerator falling back to stub: #{e.message}")
      stub
    end

    private
      def stub
        {
          "name" => @episode.name.presence || "פרק חדש",
          "kind" => @episode.kind,
          "title" => "#{@course.name}: מבוא מקוצר",
          "movie_url" => "",
          "audiobook_url" => "",
          "transcript" => "בפרק זה נסקור את הרעיונות המרכזיים של \"#{@course.name}\". " \
                          "נתחיל בהגדרות בסיסיות, נמשיך בדוגמאות מעשיות, ונסכם בנקודות המפתח לזכירה."
        }
      end

      def generate_with_claude
        prompt = <<~PROMPT
          צור תוכן לפרק בקורס בשם "#{@course.name}". תיאור הקורס: #{@course.details}.
          החזר JSON בלבד עם המפתחות: name, kind (movie או quiz), title, movie_url, audiobook_url, transcript.
          התמליל (transcript) בעברית, באורך של שתי פסקאות לפחות.
        PROMPT

        body = {
          model: MODEL,
          max_tokens: 1500,
          messages: [{ role: "user", content: prompt }]
        }

        uri = URI(API_URL)
        req = Net::HTTP::Post.new(uri)
        req["x-api-key"] = ENV["ANTHROPIC_API_KEY"]
        req["anthropic-version"] = "2023-06-01"
        req["content-type"] = "application/json"
        req.body = body.to_json

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
        text = JSON.parse(res.body).dig("content", 0, "text")
        JSON.parse(text[/\{.*\}/m])
      end
  end
end
