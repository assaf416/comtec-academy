class Document < ApplicationRecord
  belongs_to :project, optional: true # standalone library uploads have no project
  has_many :favorites, dependent: :destroy
  has_one_attached :original # the source office file for uploaded documents

  # The fixed set of AI-generated document types a project carries, plus
  # `uploaded` for office files added through the Library.
  enum :doc_type, {
    design: 0,
    models: 1,
    test_summary: 2,
    stack: 3,
    progress_report: 4,
    tables_dictionary: 5,
    code_conventions: 6,
    ai_skills: 7,
    uploaded: 8
  }

  # The eight AI dossier types (exposed via the API); `uploaded` is excluded.
  AI_DOC_TYPES = doc_types.keys - %w[uploaded]

  enum :source, { generated: 0, uploaded_file: 1 }, default: :generated

  validates :doc_type, presence: true
  # Only dossier docs are unique per project; standalone uploads (project nil) are not.
  validates :doc_type, uniqueness: { scope: :project_id }, if: :generated?
  validates :title, presence: true

  def to_html
    Academy::Markdown.render(content.to_s)
  end

  def display_title
    title.presence || I18n.t("documents.types.#{doc_type}")
  end

  def record_view!
    increment!(:views_count)
  end

  def favorited_by?(user)
    return false unless user

    favorites.exists?(user_id: user.id)
  end
end
