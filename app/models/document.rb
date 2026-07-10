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

  # Filter documents by any combination of free-text query (name + tags), project,
  # kind (doc_type) and a single tag. Blank criteria are ignored.
  scope :search, ->(q: nil, project_id: nil, doc_type: nil, tag: nil) {
    rel = all
    rel = rel.where("title LIKE :s OR tags LIKE :s", s: "%#{sanitize_sql_like(q.to_s)}%") if q.present?
    rel = rel.where(project_id: project_id) if project_id.present?
    rel = rel.where(doc_type: doc_type) if doc_type.present? && doc_types.key?(doc_type.to_s)
    rel = rel.where("tags LIKE ?", "%#{sanitize_sql_like(tag.to_s)}%") if tag.present?
    rel.order(updated_at: :desc)
  }

  def to_html
    Academy::Markdown.render(content.to_s)
  end

  def display_title
    title.presence || I18n.t("documents.types.#{doc_type}")
  end

  def record_view!
    increment!(:views_count)
  end

  # True when the source file is HTML — such documents are shown as their
  # original file in a new tab rather than through the branded markdown view.
  def html_original?
    return false unless original.attached?

    original.content_type == "text/html" || original.filename.to_s.downcase.end_with?(".html", ".htm")
  end

  def favorited_by?(user)
    return false unless user

    favorites.exists?(user_id: user.id)
  end

  # Freeform, comma-separated tags stored in the `tags` string column.
  def tag_list
    tags.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def tag_list=(value)
    list = value.is_a?(Array) ? value : value.to_s.split(",")
    self.tags = list.map { |t| t.to_s.strip }.reject(&:blank?).uniq.join(", ")
  end

  # Distinct tags across all documents, for the search filter dropdown.
  def self.all_tags
    pluck(:tags).flat_map { |t| t.to_s.split(",") }.map(&:strip).reject(&:blank?).uniq.sort
  end
end
