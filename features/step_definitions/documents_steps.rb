# --- Project & document setup ---
Given("a project {string} with slug {string}") do |name, slug|
  (@projects ||= {})[slug] = Project.create!(name: name, slug: slug)
end

Given("the project {string} has a {string} document titled {string} with content {string}") do |slug, type, title, content|
  @projects.fetch(slug).upsert_document(doc_type: type, title: title, content: content)
end

Given("the brand primary color is {string}") do |color|
  BrandTheme.instance.update!(primary_color: color)
end

# --- Admin UI (S17) ---
When("I open the project {string}") do |slug|
  visit admin_project_path(@projects.fetch(slug))
end

Then("I see the document type slot {string}") do |label|
  expect(page).to have_content(label)
end

When("I add the {string} document titled {string} with content {string}") do |type, title, content|
  visit new_admin_project_document_path(@projects.values.last, doc_type: type)
  fill_in "document_title", with: title
  fill_in "document_content", with: content
  click_button I18n.t("admin.documents.save")
end

Then("the rendered document contains a heading {string}") do |heading|
  expect(page).to have_css(".branded-doc h1", text: heading)
end

# --- Branded rendering (S19) ---
When("I view the {string} document of {string}") do |type, slug|
  project = @projects.fetch(slug)
  visit admin_project_document_path(project, project.document(type))
end

Then("the page includes the brand color {string}") do |color|
  expect(page.body).to include(color)
end

Then("the page loads a Google font") do
  expect(page.body).to include("fonts.googleapis.com")
end

# --- API (S18) ---
def api_put_document(slug, type, title:, content:, key:)
  s = ActionDispatch::Integration::Session.new(Rails.application)
  s.put "/api/v1/projects/#{slug}/documents/#{type}",
        params: { title: title, content: content }.to_json,
        headers: { "Authorization" => "Bearer #{key}", "Content-Type" => "application/json" }
  @api_status = s.response.status
  @api_body = s.response.body
end

When("the API upserts the {string} document for {string} with title {string} and content {string}") do |type, slug, title, content|
  api_put_document(slug, type, title: title, content: content, key: ENV["DOCS_API_KEY"])
end

When("the API upserts the {string} document for {string} with a bad key") do |type, slug|
  api_put_document(slug, type, title: "x", content: "x", key: "WRONG-KEY")
end

Then("the API response is {int}") do |code|
  expect(@api_status).to eq(code)
end

Then("the project {string} has a {string} document titled {string}") do |slug, type, title|
  doc = Project.find_by(slug: slug).document(type)
  expect(doc).not_to be_nil
  expect(doc.title).to eq(title)
end

Then("the project {string} has exactly {int} document(s)") do |slug, count|
  expect(Project.find_by(slug: slug).documents.count).to eq(count)
end
