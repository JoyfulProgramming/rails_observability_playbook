class UpdateUserAnalyticsJob < ApplicationJob
  def perform(user_id)
    User.find(user_id).increment!(:number_of_profile_visits)
    sleep 60
  end
end
