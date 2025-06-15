# frozen_string_literal: true

require "test_helper"
require_relative "../../app/clients/click_funnels"

class Clients::ClickFunnelsTest < ActiveSupport::TestCase
  setup do
    # Ensure environment variables are not set
    ENV.delete("CLICK_FUNNELS_WORKSPACE_ID")
    ENV.delete("CLICK_FUNNELS_API_KEY")

    @workspace_id = "test_workspace_id"
    @api_key = "test_api_key"
    @client = Clients::ClickFunnels.new(workspace_id: @workspace_id, api_key: @api_key)

    # Mock the Faraday connection
    @mock_connection = mock("connection")
    @client.stubs(:connection).returns(@mock_connection)
  end

  test "initialization with explicit credentials" do
    client = Clients::ClickFunnels.new(workspace_id: "explicit_workspace", api_key: "explicit_key")
    assert_equal "explicit_workspace", client.workspace_id
    assert_equal "explicit_key", client.api_key
  end

  test "initialization with environment variables" do
    ENV["CLICK_FUNNELS_WORKSPACE_ID"] = "env_workspace"
    ENV["CLICK_FUNNELS_API_KEY"] = "env_key"

    client = Clients::ClickFunnels.new
    assert_equal "env_workspace", client.workspace_id
    assert_equal "env_key", client.api_key

    # Clean up
    ENV.delete("CLICK_FUNNELS_WORKSPACE_ID")
    ENV.delete("CLICK_FUNNELS_API_KEY")
  end

  test "initialization raises error without workspace_id" do
    assert_raises ArgumentError do
      Clients::ClickFunnels.new(workspace_id: nil, api_key: "some_key")
    end
  end

  test "initialization raises error without api_key" do
    assert_raises ArgumentError do
      Clients::ClickFunnels.new(workspace_id: "some_workspace", api_key: nil)
    end
  end

  test "list_contacts without email filter" do
    mock_response = mock("response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns({ data: [{ id: "123", attributes: { email_address: "user@example.com" } }] }.to_json)

    @mock_connection.expects(:get)
      .with("/workspaces/#{@workspace_id}/contacts", {})
      .returns(mock_response)

    response = @client.list_contacts
    assert_equal "123", response["data"][0]["id"]
    assert_equal "user@example.com", response["data"][0]["attributes"]["email_address"]
  end

  test "list_contacts with email filter" do
    email = "test@example.com"
    mock_response = mock("response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns({ data: [{ id: "456", attributes: { email_address: email } }] }.to_json)

    @mock_connection.expects(:get)
      .with("/workspaces/#{@workspace_id}/contacts", { "filter[email_address]" => email })
      .returns(mock_response)

    response = @client.list_contacts(email_address: email)
    assert_equal "456", response["data"][0]["id"]
    assert_equal email, response["data"][0]["attributes"]["email_address"]
  end

  test "find_contact_by_email returns contact when found" do
    email = "found@example.com"
    mock_response = mock("response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns({ data: [{ id: "789", attributes: { email_address: email } }] }.to_json)

    @mock_connection.expects(:get)
      .with("/workspaces/#{@workspace_id}/contacts", { "filter[email_address]" => email })
      .returns(mock_response)

    contact = @client.find_contact_by_email(email)
    assert_equal "789", contact["id"]
  end

  test "find_contact_by_email returns nil when not found" do
    email = "notfound@example.com"
    mock_response = mock("response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns({ data: [] }.to_json)

    @mock_connection.expects(:get)
      .with("/workspaces/#{@workspace_id}/contacts", { "filter[email_address]" => email })
      .returns(mock_response)

    contact = @client.find_contact_by_email(email)
    assert_nil contact
  end

  test "create_contact_tag with default tag id" do
    contact_id = "123"
    tag_id = "328935" # Default power user tag

    mock_response = mock("response")
    mock_response.stubs(:status).returns(201)
    mock_response.stubs(:body).returns({ data: { id: "tag_123", type: "contacts_applied_tags" } }.to_json)

    expected_payload = {
      data: {
        type: "contacts_applied_tags",
        attributes: {
          contact_id: contact_id,
          tag_id: tag_id
        }
      }
    }

    @mock_connection.expects(:post)
      .with("/workspaces/#{@workspace_id}/contacts/applied_tags")
      .yields(mock("request").tap do |req|
        req.expects(:headers).returns({"Content-Type" => "application/json"})
        req.expects(:body=).with(expected_payload.to_json)
      end)
      .returns(mock_response)

    response = @client.create_contact_tag(contact_id)
    assert_equal "tag_123", response["data"]["id"]
  end

  test "create_contact_tag with custom tag id" do
    contact_id = "123"
    tag_id = "custom_tag_456"

    mock_response = mock("response")
    mock_response.stubs(:status).returns(201)
    mock_response.stubs(:body).returns({ data: { id: "tag_456", type: "contacts_applied_tags" } }.to_json)

    expected_payload = {
      data: {
        type: "contacts_applied_tags",
        attributes: {
          contact_id: contact_id,
          tag_id: tag_id
        }
      }
    }

    @mock_connection.expects(:post)
      .with("/workspaces/#{@workspace_id}/contacts/applied_tags")
      .yields(mock("request").tap do |req|
        req.expects(:headers).returns({"Content-Type" => "application/json"})
        req.expects(:body=).with(expected_payload.to_json)
      end)
      .returns(mock_response)

    response = @client.create_contact_tag(contact_id, tag_id: tag_id)
    assert_equal "tag_456", response["data"]["id"]
  end

  test "mark_as_power_user returns true when successful" do
    email = "power@example.com"
    contact_id = "power_123"

    # Mock find_contact_by_email response
    mock_list_response = mock("list_response")
    mock_list_response.stubs(:status).returns(200)
    mock_list_response.stubs(:body).returns({ data: [{ id: contact_id, attributes: { email_address: email } }] }.to_json)

    @mock_connection.expects(:get)
      .with("/workspaces/#{@workspace_id}/contacts", { "filter[email_address]" => email })
      .returns(mock_list_response)

    # Mock create_contact_tag response
    mock_tag_response = mock("tag_response")
    mock_tag_response.stubs(:status).returns(201)
    mock_tag_response.stubs(:body).returns({ data: { id: "tag_power", type: "contacts_applied_tags" } }.to_json)

    expected_payload = {
      data: {
        type: "contacts_applied_tags",
        attributes: {
          contact_id: contact_id,
          tag_id: "328935"
        }
      }
    }

    @mock_connection.expects(:post)
      .with("/workspaces/#{@workspace_id}/contacts/applied_tags")
      .yields(mock("request").tap do |req|
        req.expects(:headers).returns({"Content-Type" => "application/json"})
        req.expects(:body=).with(expected_payload.to_json)
      end)
      .returns(mock_tag_response)

    result = @client.mark_as_power_user(email)
    assert result
  end

  test "mark_as_power_user returns false when contact not found" do
    email = "notfound@example.com"

    # Mock find_contact_by_email response with empty data
    mock_response = mock("response")
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:body).returns({ data: [] }.to_json)

    @mock_connection.expects(:get)
      .with("/workspaces/#{@workspace_id}/contacts", { "filter[email_address]" => email })
      .returns(mock_response)

    result = @client.mark_as_power_user(email)
    assert_not result
  end

  test "handle_response raises error for non-success responses" do
    mock_response = mock("response")
    mock_response.stubs(:status).returns(500)
    mock_response.stubs(:body).returns("Internal Server Error")

    @mock_connection.expects(:get)
      .with("/workspaces/#{@workspace_id}/contacts", {})
      .returns(mock_response)

    assert_raises RuntimeError do
      @client.list_contacts
    end
  end
end
