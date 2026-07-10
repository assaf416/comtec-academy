class Slide < ApplicationRecord
  belongs_to :presentation
  belongs_to :layout, optional: true
  has_one_attached :audio # generated voice-over (wav)
  has_many :slide_answers, dependent: :destroy

  serialize :choices, coder: JSON, type: Array

  scope :ordered, -> { order(:position) }

  # A slide is a "code" slide when its content contains a fenced code block.
  def code?
    content.to_s.match?(/^```/)
  end

  def quiz?
    layout&.quiz? || choices.present?
  end

  def rendered_html
    Presentations::SlideRenderer.new.slide_html(content)
  end

  def answer_for(user)
    slide_answers.find_by(user: user)
  end

  # Duration used on the timeline: the narration length, or a default for
  # silent/text-only slides.
  DEFAULT_DURATION = 4.0
  def effective_duration
    duration.to_f.positive? ? duration.to_f : DEFAULT_DURATION
  end
end
