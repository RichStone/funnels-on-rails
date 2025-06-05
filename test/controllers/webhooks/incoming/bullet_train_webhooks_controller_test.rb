require "test_helper"

class Webhooks::Incoming::BulletTrainWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryBot.create(:onboarded_user)
    @membership = @user.memberships.first
    @team = @user.current_team

    @original_webhook_secret = ENV["BULLET_TRAIN_WEBHOOK_SECRET"]
    ENV["BULLET_TRAIN_WEBHOOK_SECRET"] = "test_webhook_secret"
  end

  teardown do
    ENV["BULLET_TRAIN_WEBHOOK_SECRET"] = @original_webhook_secret
  end

  test "should process incoming webhook with valid signature" do
    json_payload = sample_webhook_payload
    timestamp = Time.now.to_i.to_s
    signature = generate_signature(json_payload, timestamp)

    post "/webhooks/incoming/bullet_train_webhooks",
      params: json_payload,
      headers: {
        "X-Webhook-Bullet-Train-Signature" => signature,
        "X-Webhook-Bullet-Train-Timestamp" => timestamp,
        "Content-Type" => "application/json"
      }

    assert_response :created
    assert_equal({"status" => "OK"}, response.parsed_body)

    webhook = Webhooks::Incoming::BulletTrainWebhook.first
    assert_equal JSON.parse(json_payload), webhook.data
  end

  test "should reject incoming webhook with invalid signature" do
    json_payload = sample_webhook_payload
    timestamp = Time.now.to_i.to_s
    invalid_signature = "invalid_signature_here"

    post "/webhooks/incoming/bullet_train_webhooks",
      params: json_payload,
      headers: {
        "X-Webhook-Bullet-Train-Signature" => invalid_signature,
        "X-Webhook-Bullet-Train-Timestamp" => timestamp,
        "Content-Type" => "application/json"
      }

    assert_response :forbidden
    assert_equal({"error" => "Signature verification failed"}, response.parsed_body)

    # Verify no webhook was created
    assert_equal 0, Webhooks::Incoming::BulletTrainWebhook.count
  end

  private

  def sample_webhook_payload
    '{
      "data": {
        "id": 4,
        "name": "aaa",
        "team_id": 3,
        "created_at": "2025-06-05T09:27:41.939Z",
        "updated_at": "2025-06-05T09:27:41.939Z",
        "description": ""
      },
      "event_id": "9abb8b6e49e5e7ffab7212bce01a7f97",
      "event_type": "scaffolding/absolutely_abstract/creative_concept.created",
      "subject_id": 4,
      "subject_type": "Scaffolding::AbsolutelyAbstract::CreativeConcept"
    }'
  end

  def generate_signature(payload, timestamp)
    signature_payload = "#{timestamp}.#{payload}"
    OpenSSL::HMAC.hexdigest("SHA256", ENV["BULLET_TRAIN_WEBHOOK_SECRET"], signature_payload)
  end
end
