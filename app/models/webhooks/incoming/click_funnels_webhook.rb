class Webhooks::Incoming::ClickFunnelsWebhook < BulletTrain::Configuration.incoming_webhooks_parent_class_name.constantize
  include Webhooks::Incoming::Webhook
  include Rails.application.routes.url_helpers

  def verify_authenticity
    # We currently only verify authenticity in the controller.
    true
  end

  def process
    event_type = data.dig("event_type_id")

    case event_type
    when "form_submission.created"
      process_form_submission
    when "subscription.invoice.paid"
      process_subscription_invoice_paid
    else
      # Nothing to do here.
      {
        success: false,
        message: "Unsupported event type: #{event_type}"
      }
    end
  rescue => e
    Rails.logger.error("Error processing webhook: #{e.message}\n#{e.backtrace.join("\n")}")
    {
      success: false,
      message: "Error processing webhook: #{e.message}"
    }
  end

  private

  def process_form_submission
    email_address = data.dig("data", "data", "contact", "email")
    existing_user = User.find_by(email: email_address)

    if existing_user
      {
        success: true,
        user_id: existing_user.id,
        message: "User already exists"
      }
    else
      password = SecureRandom.hex

      user = User.new(
        email: email_address,
        password: password,
        password_confirmation: password,
        first_name: data.dig("data", "data", "first_name"),
        last_name: data.dig("data", "data", "last_name")
      )

      if user.save
        user.create_default_team
        FunnelUserMailer.welcome(user, data.dig("funnel", "name")).deliver_later

        {
          success: true,
          user_id: user.id,
          message: "User created successfully"
        }
      else
        Rails.logger.error("Failed to create user from webhook: #{user.errors.full_messages.join(", ")}")
        {
          success: false,
          errors: user.errors.full_messages
        }
      end
    end
  end

  def process_subscription_invoice_paid
    # This will be implemented later
    {
      success: true,
      message: "Subscription invoice paid event received"
    }
  end
end
