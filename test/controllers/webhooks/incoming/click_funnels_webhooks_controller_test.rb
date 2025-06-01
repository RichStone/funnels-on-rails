require "test_helper"

class Webhooks::Incoming::ClickFunnelsWebhooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @valid_ip = ENV["CLICK_FUNNELS_IP_ALLOWLIST"].split(",").sample.strip
    # TODO: Source from .env.test
    @endpoint_secret = ENV["CLICK_FUNNELS_ENDPOINT_SECRET"]
  end

  def contact_identified_payload
    file_path = Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/contact_identified.json")
    @_contact_identified_json ||= JSON.parse(File.read(file_path))
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
end
