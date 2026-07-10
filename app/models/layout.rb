class Layout < ApplicationRecord
  has_many :slides, dependent: :nullify

  enum :kind, { text: 0, code: 1, quiz: 2 }, default: :text

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :direction, inclusion: { in: %w[rtl ltr] }

  def self.for_key(key)
    find_by(key: key)
  end

  # Default layout for a slide whose screenplay didn't name one.
  def self.default_for(has_code:, has_quiz:)
    key = has_quiz ? "quiz" : (has_code ? "code-he" : "plain-he")
    for_key(key) || first
  end
end
