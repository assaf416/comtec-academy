namespace :documents do
  desc "Import example documents (md/html/office) from a folder into the Library"
  task :import, [ :path ] => :environment do |_task, args|
    path = args[:path] || Rails.root.join("documents")
    result = Docs::FolderImporter.import(path)
    puts "Imported #{result[:imported]} documents from #{path}"
  end
end
