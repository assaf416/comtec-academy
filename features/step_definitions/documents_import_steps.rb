require "tmpdir"

Given("a documents folder with a markdown and an HTML file") do
  @import_dir = Dir.mktmpdir("docs-import")
  File.write(File.join(@import_dir, "guide.md"), "# Guide\n\nHello world.")
  File.write(File.join(@import_dir, "page.html"),
             "<html><head><style>.x{color:red}</style></head><body><h1>Page</h1><p>Hi</p></body></html>")
end

When("I import that documents folder") do
  @result = Docs::FolderImporter.import(@import_dir)
end

Then("{int} documents are in the library") do |count|
  expect(Document.where(source: :uploaded_file).count).to eq(count)
end

Then("every imported document keeps its original file") do
  expect(Document.where(source: :uploaded_file).all? { |d| d.original.attached? }).to be(true)
end

Then("every imported document has markdown content") do
  expect(Document.where(source: :uploaded_file).all? { |d| d.content.present? }).to be(true)
end

Then("the imported HTML document excludes its stylesheet") do
  doc = Document.find_by!(title: "Page")
  expect(doc.content).to include("Page")
  expect(doc.content).not_to include("color:red")
end
