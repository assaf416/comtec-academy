class Episode < ApplicationRecord
  belongs_to :course
  has_many :quiz_questions, dependent: :destroy
  has_many :markdown_docs, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  # Media produced by the studio / TTS pipelines.
  has_one_attached :movie
  has_one_attached :audio
  has_one_attached :thumbnail

  enum :kind, { movie: 0, quiz: 1 }, default: :movie

  validates :name, presence: true

  scope :ordered, -> { order(:position) }

  before_validation :assign_position, on: :create

  def display_title
    title.presence || name
  end

  private
    def assign_position
      self.position ||= (course&.episodes&.maximum(:position) || 0) + 1
    end
end
