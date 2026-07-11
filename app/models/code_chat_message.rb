class CodeChatMessage < ApplicationRecord
  # Polymorphic so a code-investigation chat can attach to a snippet today and a
  # document/project later.
  belongs_to :subject, polymorphic: true
  belongs_to :user

  enum :role, { user: 0, assistant: 1 }, default: :user

  validates :body, presence: true

  scope :chronological, -> { order(:created_at) }
end
