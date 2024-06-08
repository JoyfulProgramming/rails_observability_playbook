class UpdateUserAnalyticsJob
  include Sidekiq::Job

  def perform(user_id)
    User.find(user_id).increment!(:number_of_profile_visits)
  end
end
