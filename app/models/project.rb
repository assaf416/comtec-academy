class Project < ApplicationRecord
  has_many :documents, dependent: :destroy

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
      self.slug = name.to_s.parameterize if slug.blank?
    end
end
