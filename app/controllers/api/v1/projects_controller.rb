module Api
  module V1
    class ProjectsController < Api::BaseController
      def index
        render json: { projects: Project.order(:name).map { |p| project_json(p) } }
      end

      # Idempotent by slug so agents can safely "ensure" a project exists.
      def create
        slug = params[:slug].presence || params[:name].to_s.parameterize
        project = Project.find_or_initialize_by(slug: slug)
        project.name = params[:name] if params[:name].present?
        project.description = params[:description] if params.key?(:description)
        project.name ||= slug

        if project.save
          render json: project_json(project), status: project.previously_new_record? ? :created : :ok
        else
          render json: { error: "invalid", messages: project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        project = Project.find_by(slug: params[:slug])
        return not_found("project_not_found") unless project

        render json: project_json(project, include_docs: true)
      end

      private
        def project_json(project, include_docs: false)
          json = { slug: project.slug, name: project.name, description: project.description,
                   documents_count: project.documents.count }
          if include_docs
            json[:documents] = project.documents.map do |d|
              { doc_type: d.doc_type, title: d.title, updated_at: d.updated_at,
                view_url: admin_project_document_url(project, d) }
            end
          end
          json
        end
    end
  end
end
