require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /show" do
    it "returns http success" do
      user = User.create!
      get user_path(user)
      expect(response).to have_http_status(:success)
    end
  end
end
