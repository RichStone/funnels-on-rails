require "controllers/api/v1/test"

class Api::V1::BusinessesControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @business = build(:business, team: @team)
    @other_businesses = create_list(:business, 3)

    @another_business = create(:business, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @business.save
    @another_business.save
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(business_data)
    # Fetch the business in question and prepare to compare it's attributes.
    business = Business.find(business_data["id"])

    assert_equal_or_nil business_data['name'], business.name
    assert_equal_or_nil business_data['funnel_url'], business.funnel_url
    assert_equal_or_nil business_data['app_url'], business.app_url
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal business_data["team_id"], business.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/businesses", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    business_ids_returned = response.parsed_body.map { |business| business["id"] }
    assert_includes(business_ids_returned, @business.id)

    # But not returning other people's resources.
    assert_not_includes(business_ids_returned, @other_businesses[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/businesses/#{@business.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/businesses/#{@business.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    business_data = JSON.parse(build(:business, team: nil).api_attributes.to_json)
    business_data.except!("id", "team_id", "created_at", "updated_at")
    params[:business] = business_data

    post "/api/v1/teams/#{@team.id}/businesses", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/businesses",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/businesses/#{@business.id}", params: {
      access_token: access_token,
      business: {
        name: 'Alternative String Value',
        funnel_url: 'Alternative String Value',
        app_url: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @business.reload
    assert_equal @business.name, 'Alternative String Value'
    assert_equal @business.funnel_url, 'Alternative String Value'
    assert_equal @business.app_url, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/businesses/#{@business.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Business.count", -1) do
      delete "/api/v1/businesses/#{@business.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/businesses/#{@another_business.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
