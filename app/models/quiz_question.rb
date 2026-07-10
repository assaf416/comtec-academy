class QuizQuestion < ApplicationRecord
  belongs_to :episode
  has_many :quiz_answers, dependent: :destroy

  # Stored as a JSON array of option strings (nil/empty => free-text answer).
  serialize :choices, coder: JSON, type: Array

  validates :prompt, presence: true

  def answer_for(user)
    quiz_answers.find_by(user: user)
  end
end
