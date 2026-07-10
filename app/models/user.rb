class User < ApplicationRecord
  # Password is optional until the invited user activates their account, so we
  # opt out of the default has_secure_password presence/confirmation validations
  # and enforce them ourselves during activation.
  has_secure_password validations: false

  has_many :sessions, dependent: :destroy
  has_many :quiz_answers, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_many :activities, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { student: 0, admin: 1 }, default: :student
  enum :status, { invited: 0, active: 1 }, default: :invited

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, allow_nil: true

  # Single-use invitation link: the token stops working once activated_at is set.
  generates_token_for :invitation, expires_in: 14.days do
    activated_at&.to_i
  end

  # Turn an invitation into an active account.
  def activate!(password:, password_confirmation: nil)
    self.password = password
    self.password_confirmation = password_confirmation if password_confirmation
    self.status = :active
    self.activated_at = Time.current
    save
  end

  def display_name
    name.presence || email_address
  end
end
