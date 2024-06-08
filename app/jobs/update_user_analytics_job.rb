class UpdateUserAnalyticsJob
  include Sidekiq::Job

  def perform(user_id)
    user = User.find(user_id)
    user.increment!(:number_of_profile_visits)
    user.save!
  end
end
