class Webhooks::Incoming::ClickFunnelsWebhook < BulletTrain::Configuration.incoming_webhooks_parent_class_name.constantize
  include Webhooks::Incoming::Webhook
  include Rails.application.routes.url_helpers

  def verify_authenticity
    # We currently only verify authenticity in the controller.
    true
  end

  def process
    existing_user = User.find_by(email: data.dig("data", "email_address"))

    if existing_user
      return {
        success: true,
        user_id: existing_user.id,
        message: "User already exists"
      }
    else
      password = SecureRandom.hex

      user = User.new(
        email: data.dig("data", "email_address"),
        password: password,
        password_confirmation: password,
        first_name: data.dig("data", "first_name"),
        last_name: data.dig("data", "last_name")
      )

      if user.save
        user.create_default_team
        FunnelUserMailer.welcome(user, data.dig("funnel", "name")).deliver_later

        return {
          success: true,
          user_id: user.id,
          message: "User created successfully"
        }
      else
        Rails.logger.error("Failed to create user from webhook: #{user.errors.full_messages.join(', ')}")
        return {
          success: false,
          errors: user.errors.full_messages
        }
      end
    end
  rescue => e
    Rails.logger.error("Error processing webhook: #{e.message}\n#{e.backtrace.join("\n")}")
    return {
      success: false,
      message: "Error processing webhook: #{e.message}"
    }
  end
end
