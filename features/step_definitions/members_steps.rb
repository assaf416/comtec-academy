# --- Roster import (S24) ---
When("I import the users roster") do
  @import = Users::Importer.import(Rails.root.join("db/seeds/users.xlsx"))
end

Then("at least {int} users are imported") do |count|
  expect(@import[:users]).to be >= count
end

Then("the user {string} belongs to project {string}") do |name, project_name|
  user = User.find_by!(name: name)
  expect(user.projects.pluck(:name)).to include(project_name)
end

Then("the user {string} has an avatar") do |name|
  expect(User.find_by!(name: name).avatar_source).to be_present
end

# --- Members + avatar stack ---
Given("the project {string} has {int} members") do |slug, count|
  project = @projects.fetch(slug)
  count.times do |i|
    user = create_user(name: "Member #{i}")
    project.project_memberships.create!(user: user)
  end
end

When("I open the admin project {string}") do |slug|
  visit admin_project_path(@projects.fetch(slug))
end

Then("I see {int} avatars in the members stack") do |count|
  expect(page.all(".avatar-stack img.avatar").size).to eq(count)
end

Then("I see a {string} overflow in the members stack") do |text|
  within(".avatar-stack") { expect(page).to have_content(text) }
end
