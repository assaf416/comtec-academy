require "rouge"

module SnippetsHelper
  # Server-side syntax highlighting (inline styles, no external assets — same
  # approach as the presentation slide renderer). Falls back to plain text when
  # Rouge has no lexer for the language (e.g. as400/rpg).
  def highlight_code(body, language)
    lexer = Rouge::Lexer.find(language.to_s) || Rouge::Lexers::PlainText.new
    formatter = Rouge::Formatters::HTMLInline.new(Rouge::Themes::Github.new)
    tag.pre(class: "code", dir: "ltr") do
      tag.code(formatter.format(lexer.lex(body.to_s)).html_safe)
    end
  end
end
