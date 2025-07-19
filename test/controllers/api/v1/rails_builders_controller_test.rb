require "controllers/api/v1/test"

class Api::V1::RailsBuildersControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @rails_builder = build(:rails_builder, team: @team)
    @other_rails_builders = create_list(:rails_builder, 3)

    @another_rails_builder = create(:rails_builder, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @rails_builder.save
    @another_rails_builder.save

    @original_hide_things = ENV["HIDE_THINGS"]
    ENV["HIDE_THINGS"] = "false"
    Rails.application.reload_routes!
  end

  teardown do
    ENV["HIDE_THINGS"] = @original_hide_things
    Rails.application.reload_routes!
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(rails_builder_data)
    # Fetch the rails_builder in question and prepare to compare it's attributes.
    rails_builder = RailsBuilder.find(rails_builder_data["id"])

    assert_equal_or_nil rails_builder_data["first_name"], rails_builder.first_name
    assert_equal_or_nil rails_builder_data["last_name"], rails_builder.last_name
    assert_equal_or_nil rails_builder_data["email"], rails_builder.email
    assert_equal_or_nil rails_builder_data["builder_level_id"], rails_builder.builder_level_id
    if rails_builder_data["bio_image"].nil?
      assert_not rails_builder.bio_image.attached?
    else
      assert rails_builder.bio_image.attached?
      assert_equal rails_builder_data["bio_image"]["url"], url_for(rails_builder.bio_image)
    end
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal rails_builder_data["team_id"], rails_builder.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/rails_builders", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    rails_builder_ids_returned = response.parsed_body.map { |rails_builder| rails_builder["id"] }
    assert_includes(rails_builder_ids_returned, @rails_builder.id)

    # But not returning other people's resources.
    assert_not_includes(rails_builder_ids_returned, @other_rails_builders[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/rails_builders/#{@rails_builder.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/rails_builders/#{@rails_builder.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    rails_builder_data = JSON.parse(build(:rails_builder, team: nil).api_attributes.to_json)
    rails_builder_data.except!("id", "team_id", "created_at", "updated_at")
    params[:rails_builder] = rails_builder_data

    post "/api/v1/teams/#{@team.id}/rails_builders", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/rails_builders",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/rails_builders/#{@rails_builder.id}", params: {
      access_token: access_token,
      rails_builder: {
        first_name: "Alternative String Value",
        last_name: "Alternative String Value",
        email: "alternative@example.com",
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @rails_builder.reload
    assert_equal @rails_builder.first_name, "Alternative String Value"
    assert_equal @rails_builder.last_name, "Alternative String Value"
    assert_equal @rails_builder.email, "alternative@example.com"
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/rails_builders/#{@rails_builder.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("RailsBuilder.count", -1) do
      delete "/api/v1/rails_builders/#{@rails_builder.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/rails_builders/#{@another_rails_builder.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
