module Api
  module V1
    class MetaController < Api::BaseController
      # Lets an agent discover the valid document types.
      def doc_types
        render json: {
          doc_types: Document::AI_DOC_TYPES,
          labels: Document::AI_DOC_TYPES.index_with { |k| I18n.t("documents.types.#{k}") },
          usage: "PUT /api/v1/projects/:slug/documents/:doc_type with JSON {title, content}"
        }
      end
    end
  end
end
