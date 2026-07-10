class LibraryController < ApplicationController
  def index
    @recent = Document.order(updated_at: :desc).limit(12)
    @popular = Document.where("views_count > 0").order(views_count: :desc).limit(12)
    @favorites = current_user.favorite_documents.order(updated_at: :desc)
  end
end
