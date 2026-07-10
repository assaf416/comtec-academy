class SlideAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :slide

  validates :answer, presence: true
  validates :user_id, uniqueness: { scope: :slide_id }

  def correct?
    slide.correct_choice.present? && answer == slide.correct_choice
  end
end
