module Admin
  class MarkdownDocsController < BaseController
    before_action :set_episode

    def create
      @episode.markdown_docs.create(doc_params)
      redirect_to edit_admin_course_episode_path(@course, @episode), notice: t("admin.docs.added")
    end

    def destroy
      @episode.markdown_docs.find(params[:id]).destroy
      redirect_to edit_admin_course_episode_path(@course, @episode), notice: t("admin.docs.deleted"), status: :see_other
    end

    private
      def set_episode
        @course = Course.find(params[:course_id])
        @episode = @course.episodes.find(params[:episode_id])
      end

      def doc_params
        params.require(:markdown_doc).permit(:name, :content)
      end
  end
end
