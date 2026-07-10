class MarkdownDoc < ApplicationRecord
  belongs_to :episode

  validates :name, presence: true

  def to_html
    Academy::Markdown.render(content.to_s)
  end
end
