module Admin
  class BrandThemesController < BaseController
    before_action :set_theme

    def edit
    end

    def update
      if @theme.update(theme_params)
        redirect_to edit_admin_brand_theme_path, notice: t("admin.brand_theme.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
      def set_theme
        @theme = BrandTheme.instance
      end

      def theme_params
        params.require(:brand_theme).permit(:primary_color, :accent_color, :text_color,
                                            :background_color, :heading_font, :body_font, :logo)
      end
  end
end
