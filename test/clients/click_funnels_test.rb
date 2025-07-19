require "test_helper"

class ClickFunnelsTest < ActiveSupport::TestCase
  setup do
    # Store original env vars
    @original_workspace_id = ENV["CLICK_FUNNELS_WORKSPACE_ID"]
    @original_api_key = ENV["CLICK_FUNNELS_API_KEY"]
    @original_workspace_subdomain = ENV["CLICK_FUNNELS_WORKSPACE_SUBDOMAIN"]

    # Set up test environment variables
    ENV["CLICK_FUNNELS_WORKSPACE_ID"] = "test_workspace_id"
    ENV["CLICK_FUNNELS_API_KEY"] = "test_api_key"
    ENV["CLICK_FUNNELS_WORKSPACE_SUBDOMAIN"] = "test_subdomain"

    # Load fixture data
    @contact_json = File.read(Rails.root.join("test/fixtures/click_funnels/contact.json"))
    @applied_tag_json = File.read(Rails.root.join("test/fixtures/click_funnels/applied_tag.json"))

    # Parse the JSON for easier access in tests
    @contact = JSON.parse(@contact_json)
    @applied_tag = JSON.parse(@applied_tag_json)

    # Create a client instance after setting up mocks
    @client = ClickFunnels.new
  end

  teardown do
    # Restore original env vars
    ENV["CLICK_FUNNELS_WORKSPACE_ID"] = @original_workspace_id
    ENV["CLICK_FUNNELS_API_KEY"] = @original_api_key
    ENV["CLICK_FUNNELS_WORKSPACE_SUBDOMAIN"] = @original_workspace_subdomain
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
    ENV["CLICK_FUNNELS_WORKSPACE_SUBDOMAIN"] = nil

    error = assert_raises ArgumentError do
      ClickFunnels.new
    end

    assert_equal "ClickFunnels subdomain is required", error.message
  end

  test "base_url returns the correct URL" do
    assert_equal "https://test_subdomain.myclickfunnels.com", @client.base_url
  end

  test "list_contacts without email filter" do
    # Mock CF::Workspaces::Contact.list to return contact data
    mock_contact = OpenStruct.new(@contact)
    CF::Workspaces::Contact.expects(:list)
      .with(workspace_id: "test_workspace_id")
      .returns([mock_contact])

    result = @client.list_contacts

    assert_equal 1, result.length
    assert_equal @contact["id"], result[0]["id"]
    assert_equal @contact["email_address"], result[0]["email_address"]
  end

  test "list_contacts with email filter" do
    # Mock CF::Workspaces::Contact.list to return filtered contact data
    mock_contact = OpenStruct.new(@contact)
    CF::Workspaces::Contact.expects(:list)
      .with(workspace_id: "test_workspace_id", filter: {email_address: @contact["email_address"]})
      .returns([mock_contact])

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
    # Mock CF::Contacts::AppliedTag.create to return applied tag data
    mock_applied_tag = OpenStruct.new(@applied_tag)
    CF::Contacts::AppliedTag.expects(:create)
      .with(contact_id: "123", tag_id: "328935")
      .returns(mock_applied_tag)

    result = @client.create_contact_tag("123")

    assert_equal @applied_tag["id"], result["id"]
  end

  test "create_contact_tag with custom tag_id" do
    # Mock CF::Contacts::AppliedTag.create to return applied tag data
    mock_applied_tag = OpenStruct.new(@applied_tag)
    CF::Contacts::AppliedTag.expects(:create)
      .with(contact_id: "123", tag_id: "custom_tag")
      .returns(mock_applied_tag)

    result = @client.create_contact_tag("123", tag_id: "custom_tag")

    assert_equal @applied_tag["id"], result["id"]
  end

  test "mark_as_power_user returns true when successful" do
    @client.expects(:find_contact_by_email)
      .with(@contact["email_address"])
      .returns(@contact)

    @client.expects(:create_contact_tag)
      .with(@contact["id"])
      .returns(@applied_tag)

    result = @client.mark_as_power_user(@contact["email_address"])

    assert_equal @applied_tag, result
  end

  test "mark_as_power_user returns false when contact not found" do
    @client.expects(:find_contact_by_email)
      .with("nonexistent@example.com")
      .returns(nil)

    result = @client.mark_as_power_user("nonexistent@example.com")

    assert_equal false, result
  end

  test "mark_as_power_user raises error when API returns error" do
    @client.expects(:find_contact_by_email)
      .with(@contact["email_address"])
      .returns(@contact)

    @client.expects(:create_contact_tag)
      .with(@contact["id"])
      .returns({"error" => "API error"})

    assert_raises(RuntimeError) do
      @client.mark_as_power_user(@contact["email_address"])
    end
  end
end
