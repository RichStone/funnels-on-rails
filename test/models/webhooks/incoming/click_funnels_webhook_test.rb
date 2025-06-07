require "test_helper"

class Webhooks::Incoming::ClickFunnelsWebhookTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "form_submission.created creates a new user from form submission webhook data" do
    # Setup form submission webhook data
    form_submission_data = JSON.parse(File.read(Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/form_submission_payload.json")))
    form_submission_data["data"]["data"]["contact"]["email"] = "#{SecureRandom.hex}@example.com"
    # Add first_name and last_name to the fixture for testing
    form_submission_data["data"]["data"]["first_name"] = "Test"
    form_submission_data["data"]["data"]["last_name"] = "User"
    form_submission_webhook = Webhooks::Incoming::ClickFunnelsWebhook.create!(data: form_submission_data)

    assert_difference "User.count" do
      form_submission_webhook.process
    end

    new_user = User.find_by(email: form_submission_data["data"]["data"]["contact"]["email"])

    assert_not_nil new_user
    assert_equal form_submission_data["data"]["data"]["first_name"], new_user.first_name
    assert_equal form_submission_data["data"]["data"]["last_name"], new_user.last_name
    assert_not_nil new_user.teams.first

    assert_enqueued_jobs 1
  end

  test "form_submission.created doesn't create duplicate users for form submission webhook" do
    # Setup form submission webhook data
    form_submission_data = JSON.parse(File.read(Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/form_submission_payload.json")))
    form_submission_data["data"]["data"]["contact"]["email"] = "#{SecureRandom.hex}@example.com"
    # Add first_name and last_name to the fixture for testing
    form_submission_data["data"]["data"]["first_name"] = "Test"
    form_submission_data["data"]["data"]["last_name"] = "User"
    form_submission_webhook = Webhooks::Incoming::ClickFunnelsWebhook.create!(data: form_submission_data)

    password = SecureRandom.hex
    existing_user = User.create!(
      email: form_submission_data["data"]["data"]["contact"]["email"],
      password: password,
      password_confirmation: password
    )

    # Test that no emails are sent and no users are created
    assert_no_emails do
      assert_no_difference "User.count" do
        result = form_submission_webhook.process
        assert_equal true, result[:success]
        assert_equal existing_user.id, result[:user_id]
        assert_equal "User already exists", result[:message]
      end
    end
  end

  # Subscription invoice paid webhook test
  test "subscription.invoice.paid event updates user subscription status" do
    # Setup subscription invoice paid webhook data
    subscription_invoice_data = JSON.parse(File.read(Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/subscription_invoice_paid_payload.json")))

    # Create a user with the email from the payload
    email = subscription_invoice_data["data"]["order"]["contact"]["email_address"]
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

    # Create and process the webhook
    subscription_invoice_webhook = Webhooks::Incoming::ClickFunnelsWebhook.create!(data: subscription_invoice_data)

    result = subscription_invoice_webhook.process

    # Reload the user to get the updated attributes
    user.reload

    # Verify the result and user status
    assert_equal true, result[:success]
    assert_equal user.id, result[:user_id]
    assert_equal "User subscription status updated to premium", result[:message]
    assert_equal User::SUBSCRIPTION_STATUSES[:premium], user.subscription_status
  end

  # Unsupported event type webhook test
  test "unknown events responds with not-ok" do
    # Setup unsupported event type webhook data
    unsupported_event_data = JSON.parse(File.read(Rails.root.join("test/fixtures/webhooks/incoming/click_funnels/contact_identified_payload.json")))
    unsupported_event_data["event_type_id"] = "contact.identified"
    unsupported_event_webhook = Webhooks::Incoming::ClickFunnelsWebhook.create!(data: unsupported_event_data)

    result = unsupported_event_webhook.process
    assert_equal false, result[:success]
    assert_equal "Unsupported event type: contact.identified", result[:message]
  end
end
