class Snippet < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true

  # Languages engineers share code in — Comtec's stacks plus common web/db ones.
  # Kept as a plain string (not an enum) so Rouge lexer keys map directly.
  LANGUAGES = %w[cobol rpg csharp javascript typescript sql html css ruby python java other].freeze

  enum :visibility, { org: 0, project: 1 }, default: :org

  validates :title, presence: true
  validates :body, presence: true
  validates :language, inclusion: { in: LANGUAGES }

  scope :recent, -> { order(updated_at: :desc) }

  # Free-text (title + description + body), project and language filters. Blank
  # criteria are ignored. Mirrors Document.search so the library can query both.
  scope :search, ->(q: nil, project_id: nil, language: nil) {
    rel = all
    if q.present?
      s = "%#{sanitize_sql_like(q.to_s)}%"
      rel = rel.where("title LIKE :s OR description LIKE :s OR body LIKE :s", s: s)
    end
    rel = rel.where(project_id: project_id) if project_id.present?
    rel = rel.where(language: language) if language.present? && LANGUAGES.include?(language.to_s)
    rel.recent
  }

  def display_language
    I18n.t("snippets.languages.#{language}", default: language.humanize)
  end
end
