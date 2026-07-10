class QuizAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :quiz_question

  validates :answer, presence: true
  validates :user_id, uniqueness: { scope: :quiz_question_id }
end
