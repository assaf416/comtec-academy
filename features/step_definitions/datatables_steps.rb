When("I open the admin users page") do
  visit admin_users_path
end

Then("the page has a datatable") do
  expect(page).to have_css("table[data-controller='datatable']")
end

Then("a row has a kebab actions menu") do
  expect(page).to have_css(".row-actions__toggle")
  expect(page).to have_css(".row-actions__menu", visible: :all)
end

Then("the kebab menu offers the action {string}") do |label|
  expect(page).to have_css(".row-actions__menu", text: label, visible: :all)
end
