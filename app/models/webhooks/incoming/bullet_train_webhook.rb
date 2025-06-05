class Webhooks::Incoming::BulletTrainWebhook < BulletTrain::Configuration.incoming_webhooks_parent_class_name.constantize
  include Webhooks::Incoming::Webhook

  def verify_authenticity
    # Signature is verified in the controller.
    true
  end

  def process
  end
end
