require "test_helper"

class Public::RailsBuildersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get rails_builders_community_url
    assert_response :success
  end
end
