class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :episode

  enum :role, { user: 0, assistant: 1 }, default: :user

  validates :body, presence: true

  scope :chronological, -> { order(:created_at) }
end
