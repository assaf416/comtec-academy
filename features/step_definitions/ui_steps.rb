# --- RTL Hebrew UI (S9) & framework split (S10) ---
When("a visitor opens the sign in page") do
  visit new_session_path
end

When("a visitor opens the sign in page with view {string}") do |view|
  visit new_session_path(view: view)
end

Then("the page is right-to-left in Hebrew") do
  expect(page).to have_css('html[dir="rtl"][lang="he"]', visible: :all)
end

Then("the page uses the {string} stylesheet") do |framework|
  expect(page).to have_css(%(link[href*="#{framework}"]), visible: :all)
end
