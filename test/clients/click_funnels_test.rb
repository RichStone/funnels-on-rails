require "test_helper"

class ClickFunnelsTest < ActiveSupport::TestCase
  setup do
    # Set up test environment variables
    ENV["CLICK_FUNNELS_WORKSPACE_ID"] = "test_workspace_id"
    ENV["CLICK_FUNNELS_API_KEY"] = "test_api_key"
    ENV["CLICK_FUNNELS_SUBDOMAIN"] = "test_subdomain"

    # Create a client instance
    @client = ClickFunnels.new

    # Set up a mock Faraday connection
    @mock_connection = mock
    @client.stubs(:connection).returns(@mock_connection)

    # Load fixture data
    @contact_json = File.read(Rails.root.join("test/fixtures/click_funnels/contact.json"))
    @applied_tag_json = File.read(Rails.root.join("test/fixtures/click_funnels/applied_tag.json"))

    # Parse the JSON for easier access in tests
    @contact = JSON.parse(@contact_json)
    @applied_tag = JSON.parse(@applied_tag_json)
  end

  test "initialization with environment variables" do
    client = ClickFunnels.new
    assert_equal "test_workspace_id", client.workspace_id
    assert_equal "test_api_key", client.api_key
    assert_equal "test_subdomain", client.subdomain
  end

  test "initialization with explicit parameters" do
    client = ClickFunnels.new(
      workspace_id: "custom_workspace_id",
      api_key: "custom_api_key",
      subdomain: "custom_subdomain"
    )

    assert_equal "custom_workspace_id", client.workspace_id
    assert_equal "custom_api_key", client.api_key
    assert_equal "custom_subdomain", client.subdomain
  end

  test "initialization raises error when workspace_id is missing" do
    ENV["CLICK_FUNNELS_WORKSPACE_ID"] = nil

    error = assert_raises ArgumentError do
      ClickFunnels.new
    end

    assert_equal "ClickFunnels workspace_id is required", error.message
  end

  test "initialization raises error when api_key is missing" do
    ENV["CLICK_FUNNELS_API_KEY"] = nil

    error = assert_raises ArgumentError do
      ClickFunnels.new
    end

    assert_equal "ClickFunnels api_key is required", error.message
  end

  test "initialization raises error when subdomain is missing" do
    ENV["CLICK_FUNNELS_SUBDOMAIN"] = nil

    error = assert_raises ArgumentError do
      ClickFunnels.new
    end

    assert_equal "ClickFunnels subdomain is required", error.message
  end

  test "base_url returns the correct URL" do
    assert_equal "https://test_subdomain.myclickfunnels.com", @client.base_url
  end

  test "list_contacts without email filter" do
    mock_response = mock
    mock_response.stubs(:body).returns([@contact].to_json)

    @mock_connection.expects(:get)
      .with("/api/v2/workspaces/test_workspace_id/contacts", {})
      .returns(mock_response)

    result = @client.list_contacts

    assert_equal 1, result.length
    assert_equal @contact["id"], result[0]["id"]
    assert_equal @contact["email_address"], result[0]["email_address"]
  end

  test "list_contacts with email filter" do
    mock_response = mock
    mock_response.stubs(:body).returns([@contact].to_json)

    @mock_connection.expects(:get)
      .with("/api/v2/workspaces/test_workspace_id/contacts", {"filter[email_address]" => @contact["email_address"]})
      .returns(mock_response)

    result = @client.list_contacts(email_address: @contact["email_address"])

    assert_equal 1, result.length
    assert_equal @contact["id"], result[0]["id"]
    assert_equal @contact["email_address"], result[0]["email_address"]
  end

  test "find_contact_by_email returns contact when found" do
    @client.expects(:list_contacts)
      .with(email_address: @contact["email_address"])
      .returns([@contact])

    result = @client.find_contact_by_email(@contact["email_address"])

    assert_equal @contact["id"], result["id"]
    assert_equal @contact["email_address"], result["email_address"]
  end

  test "find_contact_by_email returns nil when not found" do
    @client.expects(:list_contacts)
      .with(email_address: "nonexistent@example.com")
      .returns([])

    result = @client.find_contact_by_email("nonexistent@example.com")

    assert_nil result
  end

  test "find_contact_by_email returns nil when API returns error" do
    @client.expects(:list_contacts)
      .with(email_address: "test@example.com")
      .returns({"error" => true, "message" => "API error"})

    result = @client.find_contact_by_email("test@example.com")

    assert_nil result
  end

  test "create_contact_tag with default tag_id" do
    mock_response = mock
    mock_response.stubs(:body).returns(@applied_tag.to_json)

    expected_payload = {
      contacts_applied_tag: {
        contact_id: "123",
        tag_id: "328935"
      }
    }

    mock_request = mock
    mock_request.expects(:headers).returns({"Content-Type" => "application/json"})
    mock_request.expects(:body=).with(expected_payload.to_json)

    @mock_connection.expects(:post)
      .with("/api/v2/contacts/123/applied_tags")
      .yields(mock_request)
      .returns(mock_response)

    result = @client.create_contact_tag("123")

    assert_equal @applied_tag["id"], result["id"]
  end

  test "create_contact_tag with custom tag_id" do
    mock_response = mock
    mock_response.stubs(:body).returns(@applied_tag.to_json)

    expected_payload = {
      contacts_applied_tag: {
        contact_id: "123",
        tag_id: "custom_tag"
      }
    }

    mock_request = mock
    mock_request.expects(:headers).returns({"Content-Type" => "application/json"})
    mock_request.expects(:body=).with(expected_payload.to_json)

    @mock_connection.expects(:post)
      .with("/api/v2/contacts/123/applied_tags")
      .yields(mock_request)
      .returns(mock_response)

    result = @client.create_contact_tag("123", tag_id: "custom_tag")

    assert_equal @applied_tag["id"], result["id"]
  end

  test "mark_as_power_user returns true when successful" do
    @client.expects(:find_contact_by_email)
      .with(@contact["email_address"])
      .returns(@contact)

    @client.expects(:create_contact_tag)
      .with(@contact["id"])
      .returns({"data" => @applied_tag})

    result = @client.mark_as_power_user(@contact["email_address"])

    assert_equal true, result
  end

  test "mark_as_power_user returns false when contact not found" do
    @client.expects(:find_contact_by_email)
      .with("nonexistent@example.com")
      .returns(nil)

    result = @client.mark_as_power_user("nonexistent@example.com")

    assert_equal false, result
  end

  test "mark_as_power_user returns false when API returns error" do
    @client.expects(:find_contact_by_email)
      .with(@contact["email_address"])
      .returns(@contact)

    @client.expects(:create_contact_tag)
      .with(@contact["id"])
      .returns({"error" => "API error"})

    result = @client.mark_as_power_user(@contact["email_address"])

    assert_equal false, result
  end
end
