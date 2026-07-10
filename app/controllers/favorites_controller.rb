class FavoritesController < ApplicationController
  before_action :set_document

  def create
    current_user.favorites.find_or_create_by(document: @document)
    redirect_back fallback_location: document_path(@document)
  end

  def destroy
    current_user.favorites.where(document: @document).destroy_all
    redirect_back fallback_location: document_path(@document)
  end

  private
    def set_document
      @document = Document.find(params[:document_id])
    end
end
