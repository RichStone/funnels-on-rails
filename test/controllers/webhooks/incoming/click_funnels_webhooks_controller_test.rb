require "test_helper"

class Webhooks::Incoming::ClickFunnelsWebhooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @valid_ip = ENV["CLICK_FUNNELS_IP_ALLOWLIST"].split(",").sample.strip
    # TODO: Source from .env.test
    @endpoint_secret = ENV["CLICK_FUNNELS_ENDPOINT_SECRET"]
  end

  def contact_identified_payload
    file_path = Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/contact_identified_payload.json")
    @_contact_identified_json ||= JSON.parse(File.read(file_path))
  end

  def subscription_invoice_paid_payload
    file_path = Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/subscription_invoice_paid_payload.json")
    @_subscription_invoice_paid_json ||= JSON.parse(File.read(file_path))
  end

  test "saves incoming webhook" do
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(@valid_ip)

    post "/webhooks/incoming/click_funnels_webhooks?secret=#{@endpoint_secret}",
      params: contact_identified_payload.to_json

    assert_response :success
    assert_equal response.parsed_body, {"status" => "OK"}

    webhook = Webhooks::Incoming::ClickFunnelsWebhook.first
    assert_equal webhook.data["data"], contact_identified_payload["data"]
  end

  test "returns 403 when event sent from unverified domain" do
    ip_not_in_allowlist = "192.168.1.1"
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(ip_not_in_allowlist)
    post "/webhooks/incoming/click_funnels_webhooks?secret=#{@endpoint_secret}",
      params: contact_identified_payload.to_json

    assert_response :forbidden
    assert_equal "Webhook request from unauthorized domain", response.parsed_body["error"]
  end

  test "returns 403 when allowlist is missing" do
    original_allowlist = ENV["CLICK_FUNNELS_IP_ALLOWLIST"]
    ENV["CLICK_FUNNELS_IP_ALLOWLIST"] = nil

    post "/webhooks/incoming/click_funnels_webhooks?secret=#{@endpoint_secret}",
      params: contact_identified_payload.to_json

    assert_response :forbidden
    assert_equal "Not ready to accept ClickFunnels webhooks because no ClickFunnels IP allowlist is configured.", response.parsed_body["error"]

    ENV["CLICK_FUNNELS_IP_ALLOWLIST"] = original_allowlist
  end

  test "returns 403 when secret is invalid" do
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(@valid_ip)

    post "/webhooks/incoming/click_funnels_webhooks?secret=invalid_secret",
      params: contact_identified_payload.to_json

    assert_response :forbidden
    assert_equal "Invalid webhook secret", response.parsed_body["error"]
  end

  test "returns 403 when secret is missing" do
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(@valid_ip)

    post "/webhooks/incoming/click_funnels_webhooks",
      params: contact_identified_payload.to_json

    assert_response :forbidden
    assert_equal "Invalid webhook secret", response.parsed_body["error"]
  end

  test "returns 403 when endpoint secret is not configured" do
    original_secret = ENV["CLICK_FUNNELS_ENDPOINT_SECRET"]
    ENV["CLICK_FUNNELS_ENDPOINT_SECRET"] = nil
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(@valid_ip)

    post "/webhooks/incoming/click_funnels_webhooks?secret=#{@endpoint_secret}",
      params: contact_identified_payload.to_json

    assert_response :forbidden
    assert_equal "Not ready to accept ClickFunnels webhooks because no endpoint secret is configured.", response.parsed_body["error"]

    ENV["CLICK_FUNNELS_ENDPOINT_SECRET"] = original_secret
  end

  test "processes subscription invoice paid webhook and updates user status" do
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(@valid_ip)

    # Create a user with the email from the payload
    email = subscription_invoice_paid_payload["data"]["order"]["contact"]["email_address"]
    password = SecureRandom.hex
    user = User.create!(
      email: email,
      password: password,
      password_confirmation: password,
      first_name: "Test",
      last_name: "User"
    )

    # Ensure user doesn't have premium status initially
    assert_nil user.subscription_status

    # Send the webhook
    post "/webhooks/incoming/click_funnels_webhooks?secret=#{@endpoint_secret}",
      params: subscription_invoice_paid_payload.to_json

    assert_response :success
    assert_equal response.parsed_body, {"status" => "OK"}

    # Verify the webhook was created
    webhook = Webhooks::Incoming::ClickFunnelsWebhook.last
    assert_equal "subscription.invoice.paid", webhook.data["event_type"]

    # Process the webhook (normally done asynchronously)
    webhook.process

    # Reload the user to get the updated attributes
    user.reload

    # Verify the user status was updated
    assert_equal User::SUBSCRIPTION_STATUSES[:premium], user.subscription_status
  end
end
