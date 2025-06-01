require "test_helper"

class Webhooks::Incoming::ClickFunnelsWebhookTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @webhook_data = JSON.parse(File.read(Rails.root.join("test/fixtures/webhooks/incoming/click_funnels_payload.json")))
    @webhook_data["data"]["email_address"] = "#{SecureRandom.hex}@example.com"
    @webhook = Webhooks::Incoming::ClickFunnelsWebhook.create!(data: @webhook_data)
  end
  
  test "creates a new user from webhook data" do
    assert_difference "User.count" do
      @webhook.process
    end
    
    new_user = User.find_by(email: @webhook_data["data"]["email_address"])
    
    assert_not_nil new_user
    assert_equal @webhook_data["data"]["first_name"], new_user.first_name
    assert_equal @webhook_data["data"]["last_name"], new_user.last_name
    assert_not_nil new_user.teams.first

    assert_enqueued_jobs 1
  end
  
  test "doesn't create duplicate users" do
    password = SecureRandom.hex
    existing_user = User.create!(
      email: @webhook_data["data"]["email_address"],
      password: password,
      password_confirmation: password
    )

    # Test that no emails are sent and no users are created
    assert_no_emails do
      assert_no_difference "User.count" do
        result = @webhook.process
        assert_equal true, result[:success]
        assert_equal existing_user.id, result[:user_id]
        assert_equal "User already exists", result[:message]
      end
    end
  end
end
