class Webhooks::Incoming::ClickFunnelsWebhook < BulletTrain::Configuration.incoming_webhooks_parent_class_name.constantize
  include Webhooks::Incoming::Webhook
  include Rails.application.routes.url_helpers

  def verify_authenticity
    # We currently only verify authenticity in the controller.
    true
  end

  def process
    puts "TBD CF process behavior!"
  end
end
