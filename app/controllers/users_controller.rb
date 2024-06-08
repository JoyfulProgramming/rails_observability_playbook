class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    UpdateUserAnalyticsJob.perform_async(@user.id)
  end
end
