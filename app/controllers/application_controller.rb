class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :layout_by_device

  before_action :remember_view_override
  helper_method :mobile_device?, :css_framework

  private
    # Choose the CSS framework layout: Bulma on mobile, Bootstrap on the web.
    def layout_by_device
      mobile_device? ? "mobile" : "application"
    end

    # Let ?view=mobile|web pin a framework (handy for testing on a desktop).
    def remember_view_override
      session[:view_override] = params[:view] if %w[mobile web].include?(params[:view])
    end

    def mobile_device?
      case session[:view_override]
      when "mobile" then true
      when "web"    then false
      else request.user_agent.to_s.match?(/Mobile|Android|iPhone|iPad|iPod|Opera Mini|IEMobile|BlackBerry/i)
      end
    end

    def css_framework
      mobile_device? ? :bulma : :bootstrap
    end
end
