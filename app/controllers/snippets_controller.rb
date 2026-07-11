class SnippetsController < ApplicationController
  def index
    @snippets = Snippet.includes(:user, :project).recent
    @language = params[:language].presence
    @snippets = @snippets.where(language: @language) if @language && Snippet::LANGUAGES.include?(@language)
  end

  def show
    @snippet = Snippet.find(params[:id])
    Activity.track(current_user, "snippet_viewed", subject: @snippet)
  end

  def new
    @snippet = Snippet.new
  end

  def create
    @snippet = Snippet.new(snippet_params)
    @snippet.user = current_user

    if @snippet.save
      Activity.track(current_user, "snippet_created", subject: @snippet)
      redirect_to snippet_path(@snippet), notice: t("snippets.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def snippet_params
      params.require(:snippet).permit(:title, :language, :body, :description, :project_id, :visibility)
    end
end
