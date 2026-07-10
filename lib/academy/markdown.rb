require "redcarpet"

module Academy
  # Renders episode markdown documents to safe HTML.
  module Markdown
    RENDERER = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(filter_html: true, safe_links_only: true, hard_wrap: true),
      autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true
    )

    def self.render(text)
      RENDERER.render(text.to_s).html_safe
    end
  end
end
