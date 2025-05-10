require "test_helper"

class Webhooks::Incoming::ClickFunnelsWebhooksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def contact_identified_payload
    file_path = Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/contact_identified.json")
    @_contact_identified_json ||= JSON.parse(File.read(file_path))
  end

  test "should get incoming webhook" do
    post "/webhooks/incoming/click_funnels_webhooks", params: contact_identified_payload.to_json
    assert_equal response.parsed_body, {"status" => "OK"}

    webhook = Webhooks::Incoming::ClickFunnelsWebhook.first
    assert_equal webhook.data["data"], contact_identified_payload["data"]
  end
end
