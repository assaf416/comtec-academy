module Admin
  class LayoutsController < BaseController
    before_action :set_layout, only: %i[edit update destroy]

    def index
      @layouts = Layout.order(:key)
    end

    def new
      @layout = Layout.new(direction: "rtl", kind: :text)
    end

    def create
      @layout = Layout.new(layout_params)
      if @layout.save
        redirect_to admin_layouts_path, notice: t("admin.layouts.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @layout.update(layout_params)
        redirect_to admin_layouts_path, notice: t("admin.layouts.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @layout.destroy
      redirect_to admin_layouts_path, notice: t("admin.layouts.deleted"), status: :see_other
    end

    private
      def set_layout
        @layout = Layout.find(params[:id])
      end

      def layout_params
        params.require(:layout).permit(:key, :name, :direction, :kind, :css, :description)
      end
  end
end
