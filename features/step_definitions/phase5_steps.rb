# --- Markdown docs (S8) ---
Given("the episode {string} has a markdown doc {string} with content {string}") do |title, name, content|
  @episodes.fetch(title).markdown_docs.create!(name: name, content: content)
end

Then("I see the document {string}") do |name|
  expect(page).to have_content(name)
end

Then("the document renders a heading {string}") do |heading|
  expect(page).to have_css("h1", text: heading)
end

# --- Episode chat (S7) ---
When("I post the chat message {string}") do |body|
  fill_in "body", with: body
  click_button I18n.t("chat.send")
end

Then("the chat thread contains {string}") do |body|
  expect(page).to have_css("#chat-thread", text: body)
end

# --- Activity tracking (S12) ---
When("I open the activity dashboard") do
  visit admin_activities_path
end

Then("I see a {string} activity for {string}") do |action, name|
  expect(page).to have_content(I18n.t("admin.activities.actions.#{action}"))
  expect(page).to have_content(name)
end

# --- Admin episode content editing (S13) ---
When("I add a movie episode titled {string} with transcript {string} to {string}") do |title, transcript, course|
  visit new_admin_course_episode_path(@courses.fetch(course))
  fill_in "episode_title", with: title
  fill_in "episode_name", with: title
  fill_in "episode_transcript", with: transcript
  click_button I18n.t("admin.episodes.save")
end

Then("the course {string} has an episode {string} with transcript {string}") do |course, title, transcript|
  episode = @courses.fetch(course).episodes.find_by(title: title)
  expect(episode).not_to be_nil
  expect(episode.transcript).to eq(transcript)
end

# --- AI content / TTS / Studio (S14, S15, S16) ---
When("I generate content with AI for the episode {string} in {string}") do |title, course|
  visit edit_admin_course_episode_path(@courses.fetch(course), @episodes.fetch(title))
  click_button I18n.t("admin.episodes.generate_content")
end

When("I generate the Hebrew podcast for the episode {string} in {string}") do |title, course|
  visit edit_admin_course_episode_path(@courses.fetch(course), @episodes.fetch(title))
  click_button I18n.t("admin.episodes.generate_audio")
end

When("I assemble the movie for the episode {string} in {string}") do |title, course|
  visit admin_course_episode_studio_path(@courses.fetch(course), @episodes.fetch(title))
  click_button I18n.t("admin.studio.assemble")
end

Then("the episode {string} has a title") do |title|
  expect(@episodes.fetch(title).reload.title).to be_present
end

Then("the episode {string} has a transcript") do |title|
  expect(@episodes.fetch(title).reload.transcript).to be_present
end

Then("the episode {string} has an audio attachment") do |title|
  expect(@episodes.fetch(title).reload.audio).to be_attached
end

Then("the episode {string} has a movie attachment") do |title|
  expect(@episodes.fetch(title).reload.movie).to be_attached
end
