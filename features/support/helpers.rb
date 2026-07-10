# Domain-level helpers shared across step definitions. We create records
# directly and sign in through the real form so scenarios stay close to the
# model rather than brittle UI flows.
module AcademyHelpers
  def create_user(name:, role: :student, status: :active, password: "password123", email: nil)
    email ||= "#{name.downcase.gsub(/\s+/, '.')}@comtecglobal.com"
    User.create!(
      email_address: email,
      name: name,
      role: role,
      status: status,
      invited_at: Time.current,
      activated_at: (status.to_sym == :active ? Time.current : nil),
      password: password
    )
  end

  def sign_in(user, password: "password123")
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button I18n.t("auth.sign_in")
  end
end

World(AcademyHelpers)
World(Rails.application.routes.url_helpers)
