# --- User setup ---
Given("an active student named {string}") do |name|
  (@users ||= {})[name] = create_user(name: name, role: :student)
end

Given("an active admin named {string}") do |name|
  (@users ||= {})[name] = create_user(name: name, role: :admin)
end

Given("I am signed in as {string}") do |name|
  @current_user = @users.fetch(name)
  sign_in(@current_user)
end

# --- Invitation & activation (S3) ---
Given("an admin invites {string}") do |email|
  @admin = create_user(name: "Assaf", role: :admin)
  sign_in(@admin)
  visit new_admin_user_path
  fill_in "user_email_address", with: email
  click_button I18n.t("admin.users.save")
end

Then("an invitation email is sent to {string}") do |email|
  mail = ActionMailer::Base.deliveries.last
  expect(mail).not_to be_nil
  expect(mail.to).to include(email)
end

When("the user opens the activation link and sets password {string}") do |password|
  mail = ActionMailer::Base.deliveries.last
  body = (mail.text_part || mail).decoded
  link = body[%r{https?://[^\s"'<>]+/activate/[^\s"'<>]+}]
  expect(link).not_to be_nil
  visit link
  fill_in "password", with: password
  fill_in "password_confirmation", with: password
  click_button I18n.t("invitation.activate")
end

Then("the user {string} is active") do |email|
  expect(User.find_by(email_address: email)).to be_active
end

# --- Roles (S4) ---
When("{string} visits the admin dashboard") do |name|
  sign_in(@users.fetch(name))
  visit admin_root_path
end

Then("access is denied") do
  expect(page).to have_current_path(root_path)
  expect(page).to have_content(I18n.t("auth.admins_only"))
end

Then("the admin dashboard is shown") do
  expect(page).to have_content(I18n.t("admin.dashboard.title"))
end

# --- Admin user management (S11) ---
When("I invite the user {string}") do |email|
  visit new_admin_user_path
  fill_in "user_email_address", with: email
  click_button I18n.t("admin.users.save")
end

Then("{string} appears in the users list with status {string}") do |email, status|
  expect(page).to have_content(email)
  expect(page).to have_content(I18n.t("admin.users.statuses.#{status}"))
end
