module Api
  # Base for the shared-secret JSON API used by agents/scripts. Bypasses the
  # session-based auth and CSRF entirely; callers present DOCS_API_KEY.
  class BaseController < ActionController::Base
    skip_forgery_protection
    before_action :authenticate_api!

    private
      def api_key
        # In development, default so the API works out of the box.
        ENV["DOCS_API_KEY"].presence ||
          (Rails.env.development? ? "dev-docs-key" : nil)
      end

      def authenticate_api!
        key = api_key
        if key.blank?
          return render json: { error: "api_disabled", message: "Set DOCS_API_KEY to enable the API." }, status: :service_unavailable
        end

        unless ActiveSupport::SecurityUtils.secure_compare(presented_key.to_s, key)
          render json: { error: "unauthorized" }, status: :unauthorized
        end
      end

      # Accepts either "Authorization: Bearer <key>" or "X-Api-Key: <key>".
      def presented_key
        bearer = request.authorization.to_s[/\ABearer\s+(.+)\z/i, 1]
        bearer || request.headers["X-Api-Key"]
      end

      def not_found(message = "not_found")
        render json: { error: message }, status: :not_found
      end
  end
end
