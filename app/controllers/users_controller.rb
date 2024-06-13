class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    UpdateUserAnalyticsJob.perform_later(@user.id)
  end
end
