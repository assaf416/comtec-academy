require "tmpdir"

class ExportPresentationPdfJob < ApplicationJob
  queue_as :default

  def perform(presentation)
    return unless Media::Chrome.available?

    Dir.mktmpdir("pres-pdf") do |dir|
      html = File.join(dir, "deck.html")
      File.write(html, Presentations::SlideRenderer.new.deck_html(presentation))
      pdf = File.join(dir, "deck.pdf")
      Media::Chrome.to_pdf(html, pdf)
      File.open(pdf) do |f|
        presentation.pdf.attach(io: f, filename: "#{filename(presentation)}.pdf", content_type: "application/pdf")
      end
    end
  end

  private
    def filename(presentation)
      presentation.title.parameterize.presence || "presentation-#{presentation.id}"
    end
end
