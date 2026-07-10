class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :subject, polymorphic: true, optional: true

  serialize :metadata, coder: JSON, type: Hash

  scope :recent, -> { order(created_at: :desc) }

  # Record an activity; never raises so it can't break the request path.
  def self.track(user, action, subject: nil, **metadata)
    return unless user

    create!(user: user, action: action, subject: subject, metadata: metadata)
  rescue => e
    Rails.logger.warn("Activity.track failed: #{e.message}")
    nil
  end
end
