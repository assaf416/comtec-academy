module Api
  module V1
    class DocumentsController < Api::BaseController
      before_action :set_project
      before_action :validate_doc_type

      def show
        doc = @project.document(params[:doc_type])
        return not_found("document_not_found") unless doc

        render json: document_json(doc, rendered: true)
      end

      # Create or replace the document of this type (the main "generate" call).
      def upsert
        doc = @project.upsert_document(
          doc_type: params[:doc_type],
          title: params[:title].presence || I18n.t("documents.types.#{params[:doc_type]}"),
          content: params[:content].to_s
        )
        doc.update(tag_list: params[:tags]) if params.key?(:tags) && doc.persisted?

        if doc.persisted? && doc.errors.empty?
          render json: document_json(doc), status: :ok
        else
          render json: { error: "invalid", messages: doc.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
        def set_project
          @project = Project.find_by(slug: params[:project_slug])
          not_found("project_not_found") unless @project
        end

        def validate_doc_type
          return if @project.nil? # already 404'd
          unless Document::AI_DOC_TYPES.include?(params[:doc_type])
            render json: { error: "invalid_doc_type", valid: Document::AI_DOC_TYPES }, status: :unprocessable_entity
          end
        end

        def document_json(doc, rendered: false)
          json = { project: @project.slug, doc_type: doc.doc_type, title: doc.title,
                   content: doc.content, tags: doc.tag_list, updated_at: doc.updated_at,
                   view_url: admin_project_document_url(@project, doc) }
          json[:html] = doc.to_html if rendered
          json
        end
    end
  end
end
