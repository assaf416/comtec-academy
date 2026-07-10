module Admin
  class DashboardController < BaseController
    def index
      @users_count = User.count
      @active_count = User.active.count
      @invited_count = User.invited.count
    end
  end
end
