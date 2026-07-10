module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy resend_invitation]

    def index
      @users = User.order(created_at: :desc)
    end

    def show
    end

    def new
      @user = User.new(role: :student)
    end

    # Invite a user by their company email; an activation email goes out.
    def create
      @user = User.new(invite_params)
      @user.status = :invited
      @user.invited_at = Time.current

      if @user.save
        SendInvitationJob.perform_later(@user)
        redirect_to admin_users_path, notice: t("admin.users.invited", email: @user.email_address)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @user.update(update_params)
        redirect_to admin_users_path, notice: t("admin.users.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: t("admin.users.deleted"), status: :see_other
    end

    def resend_invitation
      SendInvitationJob.perform_later(@user)
      redirect_to admin_users_path, notice: t("admin.users.reinvited", email: @user.email_address)
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def invite_params
        params.require(:user).permit(:email_address, :name, :role)
      end

      def update_params
        params.require(:user).permit(:name, :role)
      end
  end
end
