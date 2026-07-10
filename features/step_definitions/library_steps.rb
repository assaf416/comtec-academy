# --- Library (S20) ---
Given("the document {string} has {int} views") do |title, views|
  Document.find_by!(title: title).update_column(:views_count, views)
end

When("I open the library") do
  visit library_path
end

Then("I see {string} in the library") do |title|
  expect(page).to have_content(title)
end

Then("I see {string} under {string}") do |title, section|
  within("#library-#{section}") { expect(page).to have_content(title) }
end

# --- Library search (S23) ---
Given("the document {string} is tagged {string}") do |title, tags|
  Document.find_by!(title: title).update!(tag_list: tags)
end

When("I search the library for {string}") do |q|
  visit library_path(q: q)
end

When("I filter the library by project {string}") do |slug|
  visit library_path(project_id: @projects.fetch(slug).id)
end

When("I filter the library by kind {string}") do |kind|
  visit library_path(doc_type: kind)
end

When("I filter the library by tag {string}") do |tag|
  visit library_path(tag: tag)
end

Then("I see {string} in the results") do |title|
  within("#library-results") { expect(page).to have_content(title) }
end

Then("I do not see {string} in the results") do |title|
  within("#library-results") { expect(page).to have_no_content(title) }
end

# --- Office upload (S21) ---
When("I upload the office file {string}") do |filename|
  visit new_admin_upload_path
  attach_file "file", Rails.root.join("features/fixtures", filename)
  click_button I18n.t("admin.uploads.submit")
end

Then("a library document is created from {string}") do |filename|
  @uploaded = Document.where(source: :uploaded_file).order(:created_at).last
  expect(@uploaded).not_to be_nil
  expect(@uploaded.title).to eq(File.basename(filename, ".*"))
end

Then("that document keeps its original file") do
  expect(@uploaded.original).to be_attached
end

Then("that document has markdown content") do
  expect(@uploaded.reload.content).to be_present
end

# --- Favorites (S22) ---
When("I open the document {string}") do |title|
  visit document_path(Document.find_by!(title: title))
end

When("I favorite the document") do
  click_button "♡ #{I18n.t('document_view.favorite')}"
end

Then("{string} is in my favorites") do |title|
  expect(@current_user.favorite_documents.exists?(title: title)).to be(true)
end
