Then("no head script loads from a public CDN") do
  expect(page).to have_no_css("script[src^='http']", visible: :all)
end

Then("the DataTables script is deferred and same-origin") do
  expect(page).to have_css("script[src^='/assets/'][src*='dataTables'][defer]", visible: :all)
end

Then("Font Awesome is served from the app, not a CDN") do
  expect(page).to have_css("link[href='/fontawesome/css/all.min.css']", visible: :all)
  expect(page).to have_no_css("link[href*='cdnjs']", visible: :all)
end
