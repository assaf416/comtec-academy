class Course < ApplicationRecord
  has_many :episodes, -> { order(:position) }, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true

  scope :published, -> { where(published: true) }
end
