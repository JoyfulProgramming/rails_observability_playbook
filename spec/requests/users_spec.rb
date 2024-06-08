require "rails_helper"
require "sidekiq/testing"

RSpec.describe "Users", type: :request do
  describe "GET /show" do
    it "returns http success" do
      Sidekiq::Testing.inline!
      user = User.create!

      get user_path(user)

      expect(response).to have_http_status(:success)
      expect(user.reload.number_of_profile_visits).to eq(1)
    end
  end
end
