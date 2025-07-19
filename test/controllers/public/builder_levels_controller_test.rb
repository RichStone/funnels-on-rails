require "test_helper"

class Public::BuilderLevelsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get builder_levels_url
    assert_response :success
  end
end
