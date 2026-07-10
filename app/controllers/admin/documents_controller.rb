module Admin
  class DocumentsController < BaseController
    before_action :set_project
    before_action :set_document, only: %i[show edit update destroy]

    def show
    end

    def new
      @document = @project.documents.new(doc_type: params[:doc_type])
    end

    def create
      @document = @project.documents.new(document_params)
      if @document.save
        redirect_to admin_project_document_path(@project, @document), notice: t("admin.documents.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @document.update(document_params)
        redirect_to admin_project_document_path(@project, @document), notice: t("admin.documents.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @document.destroy
      redirect_to admin_project_path(@project), notice: t("admin.documents.deleted"), status: :see_other
    end

    private
      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_document
        @document = @project.documents.find(params[:id])
      end

      def document_params
        params.require(:document).permit(:doc_type, :title, :content)
      end
  end
end
