module Admin
  class ActivitiesController < BaseController
    def index
      @activities = Activity.includes(:user).recent.limit(200)
      @by_user = @activities.group_by(&:user)
    end
  end
end
