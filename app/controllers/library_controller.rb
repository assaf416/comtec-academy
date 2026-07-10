class LibraryController < ApplicationController
  def index
    @projects = Project.order(:name)
    @kinds = Document.doc_types.keys
    @tags = Document.all_tags
    @query = { q: params[:q], project_id: params[:project_id], doc_type: params[:doc_type], tag: params[:tag] }
    @searching = @query.values.any?(&:present?)

    if @searching
      @results = Document.search(**@query.symbolize_keys)
    else
      @recent = Document.order(updated_at: :desc).limit(12)
      @popular = Document.where("views_count > 0").order(views_count: :desc).limit(12)
      @favorites = current_user.favorite_documents.order(updated_at: :desc)
    end
  end
end
