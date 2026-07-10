require "redcarpet"
require "rouge"

module Presentations
  # Renders slide markdown to HTML with server-side Rouge code highlighting
  # (inline styles, so the Chrome/PDF render needs no external assets). Used for
  # both the live preview and the exported deck.
  class SlideRenderer
    class HTMLWithRouge < Redcarpet::Render::HTML
      def block_code(code, language)
        lexer = Rouge::Lexer.find(language.to_s) || Rouge::Lexers::PlainText
        formatter = Rouge::Formatters::HTMLInline.new(Rouge::Themes::Github.new)
        %(<pre class="code" dir="ltr"><code>#{formatter.format(lexer.lex(code))}</code></pre>)
      end
    end

    def markdown
      @markdown ||= Redcarpet::Markdown.new(
        HTMLWithRouge.new(hard_wrap: true),
        fenced_code_blocks: true, tables: true, autolink: true, no_intra_emphasis: true
      )
    end

    def slide_html(content)
      markdown.render(content.to_s).html_safe
    end

    # A slide wrapped in its layout (direction + CSS backdrop). `include_quiz`
    # renders a static choices list (for the deck/PDF); the viewer passes false
    # and renders its own interactive quiz form.
    def slide_body(slide, include_quiz: true)
      layout = slide.layout
      key = layout&.key || "plain-he"
      dir = layout&.direction || "rtl"
      quiz = include_quiz && slide.quiz? ? quiz_list(slide) : ""
      %(<section class="slide layout-#{key}" dir="#{dir}"><style>#{layout&.css}</style>#{slide_html(slide.content)}#{quiz}</section>).html_safe
    end

    def quiz_list(slide)
      return "" if slide.choices.blank?

      items = slide.choices.map { |c| "<li>#{ERB::Util.html_escape(c)}</li>" }.join
      %(<ul class="choices">#{items}</ul>)
    end

    # A full standalone HTML deck (one page per slide) for Chrome -> PDF.
    def deck_html(presentation)
      body = presentation.slides.ordered.map { |slide| slide_body(slide) }.join("\n")

      <<~HTML
        <!DOCTYPE html>
        <html dir="rtl" lang="he"><head><meta charset="utf-8"><style>#{css}</style></head>
        <body>#{body}</body></html>
      HTML
    end

    private
      def css
        <<~CSS
          @page { size: 1280px 720px; margin: 0; }
          * { box-sizing: border-box; }
          body { margin: 0; font-family: "Heebo","Assistant","DejaVu Sans",system-ui,sans-serif; }
          .slide { width: 1280px; height: 720px; padding: 64px; page-break-after: always;
                   display: flex; flex-direction: column; justify-content: center;
                   background: #ffffff; color: #1f2937; overflow: hidden; }
          .slide h1, .slide h2, .slide h3 { color: #1f3a93; margin: 0 0 .4em; }
          .slide h1 { font-size: 52px; } .slide h2 { font-size: 40px; }
          .slide p, .slide li { font-size: 28px; line-height: 1.6; }
          pre.code { direction: ltr; text-align: left; background: #f6f8fa; border: 1px solid #e1e4e8;
                     border-radius: 12px; padding: 24px; font-size: 22px; line-height: 1.5; overflow: hidden; }
          pre.code code { font-family: "DejaVu Sans Mono","Courier New",monospace; white-space: pre-wrap; }
        CSS
      end
  end
end
