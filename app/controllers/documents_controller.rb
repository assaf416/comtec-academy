class DocumentsController < ApplicationController
  # Read-only, branded view of any document for signed-in users (the Library
  # links here). Admin editing lives under Admin::DocumentsController.
  def show
    @document = Document.find(params[:id])
    @document.record_view!
  end
end
