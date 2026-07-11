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

  def display_language
    I18n.t("snippets.languages.#{language}", default: language.humanize)
  end
end
