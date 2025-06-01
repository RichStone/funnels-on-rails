class Webhooks::Incoming::ClickFunnelsWebhooksController < Webhooks::Incoming::WebhooksController
  class UnverifiedDomainError < StandardError; end

  class InvalidSecretError < StandardError; end

  def create
    verify_source_ip
    verify_endpoint_secret_param

    webhook = Webhooks::Incoming::ClickFunnelsWebhook.create(data: JSON.parse(request.raw_post))
    webhook.process_async
    render json: {status: "OK"}, status: :created
  rescue UnverifiedDomainError, InvalidSecretError => e
    # Usually we wouldn't expose that there is an endpoint at all, but this app is open source.
    render json: {error: e.message}, status: :forbidden
  rescue JSON::ParserError
    render json: {error: "Invalid JSON payload"}, status: :bad_request
  end

  private

  def verify_source_ip
    source_ip = request.remote_ip
    allowlist = ENV["CLICK_FUNNELS_IP_ALLOWLIST"]&.split(",")&.map(&:strip) || []

    if allowlist.empty?
      Rails.logger.warn("No ClickFunnels IP allowlist configured. Set CLICK_FUNNELS_IP_ALLOWLIST environment variable.")
      raise UnverifiedDomainError, "Not ready to accept ClickFunnels webhooks because no ClickFunnels IP allowlist is configured."
    end

    unless allowlist.include?(source_ip)
      Rails.logger.error("Rejected webhook from unauthorized IP: #{source_ip}")
      raise UnverifiedDomainError, "Webhook request from unauthorized domain"
    end

    true
  end

  def verify_endpoint_secret_param
    expected_secret = ENV["CLICK_FUNNELS_ENDPOINT_SECRET"]
    provided_secret = params[:secret]

    if expected_secret.blank?
      Rails.logger.warn("No ClickFunnels endpoint secret configured. Set CLICK_FUNNELS_ENDPOINT_SECRET environment variable.")
      raise InvalidSecretError, "Not ready to accept ClickFunnels webhooks because no endpoint secret is configured."
    end

    unless provided_secret.present? && ActiveSupport::SecurityUtils.secure_compare(provided_secret, expected_secret)
      Rails.logger.error("Rejected webhook with invalid secret")
      raise InvalidSecretError, "Invalid webhook secret"
    end

    true
  end
end
