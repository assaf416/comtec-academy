# --- Code snippets (S30) ---
Given("a snippet {string} in {string} by {string}") do |title, lang, author|
  Snippet.create!(title: title, language: lang, body: "// #{title}\ncode();", user: @users.fetch(author))
end

When("I create a snippet titled {string} in language {string}") do |title, lang|
  visit new_snippet_path
  fill_in "snippet_title", with: title
  select I18n.t("snippets.languages.#{lang}"), from: "snippet_language"
  fill_in "snippet_body", with: "IDENTIFICATION DIVISION.\nPROGRAM-ID. BATCH."
  click_button I18n.t("snippets.save")
end

When("I visit the snippets page") do
  visit snippets_path
end

Then("the snippet {string} is listed") do |title|
  visit snippets_path
  expect(page).to have_content(title)
end

Then("I can view the snippet {string} with highlighted code") do |title|
  snippet = Snippet.find_by!(title: title)
  visit snippet_path(snippet)
  expect(page).to have_content(title)
  expect(page).to have_css("pre.code code")
end
