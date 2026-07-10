class Presentation < ApplicationRecord
  has_many :slides, -> { order(:position) }, dependent: :destroy
  has_one_attached :pdf
  has_one_attached :movie
  has_one_attached :background_music

  enum :status, { draft: 0, ready: 1 }, default: :draft

  validates :title, presence: true

  # (Re)build the slides from the markdown screenplay.
  def sync_slides!
    Presentations::Builder.sync!(self)
  end

  def total_duration
    slides.sum { |s| s.duration.to_f }
  end
end
