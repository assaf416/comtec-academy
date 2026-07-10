require "tmpdir"

class ConvertOfficeDocumentJob < ApplicationJob
  queue_as :default

  # Downloads the attached original office file, converts it to markdown and
  # stores it as the document body.
  def perform(document)
    return unless document.original.attached?

    ext = File.extname(document.original.filename.to_s)
    Dir.mktmpdir("upload") do |dir|
      path = File.join(dir, "source#{ext}")
      File.binwrite(path, document.original.download)
      markdown = Docs::OfficeConverter.new.convert(path, document.original.filename.to_s)
      document.update!(content: markdown)
    end
  end
end
