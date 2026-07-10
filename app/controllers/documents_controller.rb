class DocumentsController < ApplicationController
  before_action :set_document

  # Read-only view for signed-in users (the Library links here). HTML-sourced
  # documents are shown as their original file; others use the branded markdown view.
  def show
    @document.record_view!
    redirect_to raw_document_path(@document) if @document.html_original?
  end

  # Serve the original file inline with no app layout — used for HTML documents,
  # opened in a new tab from the Library.
  def raw
    return redirect_to document_path(@document) unless @document.original.attached?

    @document.record_view!
    send_data @document.original.download,
              type: @document.original.content_type.presence || "text/html",
              disposition: "inline",
              filename: @document.original.filename.to_s
  end

  private
    def set_document
      @document = Document.find(params[:id])
    end
end
