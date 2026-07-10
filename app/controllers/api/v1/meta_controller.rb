module Api
  module V1
    class MetaController < Api::BaseController
      # Lets an agent discover the valid document types.
      def doc_types
        render json: {
          doc_types: Document.doc_types.keys,
          labels: Document.doc_types.keys.index_with { |k| I18n.t("documents.types.#{k}") },
          usage: "PUT /api/v1/projects/:slug/documents/:doc_type with JSON {title, content}"
        }
      end
    end
  end
end
