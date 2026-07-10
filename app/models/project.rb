class Project < ApplicationRecord
  has_many :documents, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9][a-z0-9\-]*\z/, message: "lowercase letters, digits and hyphens only" }

  before_validation :ensure_slug

  # Returns the document of a given type, or nil.
  def document(doc_type)
    documents.find_by(doc_type: doc_type)
  end

  # Upsert a document of the given type (used by the API and admin).
  def upsert_document(doc_type:, title:, content:)
    doc = documents.find_or_initialize_by(doc_type: doc_type)
    doc.update(title: title, content: content)
    doc
  end

  private
    def ensure_slug
      return if slug.present?

      # parameterize strips non-Latin characters (e.g. Hebrew names) to "" — fall
      # back to a short unique slug so such projects still validate.
      base = name.to_s.parameterize
      self.slug = base.presence || "project-#{SecureRandom.hex(3)}"
    end
end
