class Document < ApplicationRecord
  belongs_to :project

  # The fixed set of AI-generated document types a project carries.
  enum :doc_type, {
    design: 0,
    models: 1,
    test_summary: 2,
    stack: 3,
    progress_report: 4,
    tables_dictionary: 5,
    code_conventions: 6,
    ai_skills: 7
  }

  validates :doc_type, presence: true, uniqueness: { scope: :project_id }
  validates :title, presence: true

  def to_html
    Academy::Markdown.render(content.to_s)
  end

  def display_title
    title.presence || I18n.t("documents.types.#{doc_type}")
  end
end
