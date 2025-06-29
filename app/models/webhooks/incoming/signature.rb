# A usage example of using Bullet Train's webhook signature verification
# methods.
class Webhooks::Incoming::Signature
  # Verifies the authenticity of a webhook request.
  #
  # @param payload [String] The raw request body as a string.
  # @param timestamp [String] The timestamp from the Timestamp request header.
  # @param signature [String] The signature from the Signature request header.
  # @param secret [String] The webhook secret attached to the endpoint the event comes from.
  # @return [Boolean] True if the signature is valid, false otherwise.
  def self.verify(payload, signature, timestamp, secret)
    return false if payload.blank? || signature.blank? || timestamp.blank? || secret.blank?

    tolerance_seconds = 300
    # Check if the timestamp is too old
    timestamp_int = timestamp.to_i
    now = Time.now.to_i

    if (now - timestamp_int).abs > tolerance_seconds
      return false # Webhook is too old or timestamp is from the future
    end

    # Compute the expected signature
    signature_payload = "#{timestamp}.#{payload}"
    expected_signature = OpenSSL::HMAC.hexdigest("SHA256", secret, signature_payload)

    # Compare signatures using constant-time comparison to prevent timing attacks
    ActiveSupport::SecurityUtils.secure_compare(expected_signature, signature)
  end

  # A Rails controller helper example to verify webhook requests.
  #
  # @param request [ActionDispatch::Request] The Rails request object.
  # @param secret [String] The webhook secret shared with the sender.
  # @return [Boolean] True if the signature is valid, false otherwise.
  def self.verify_request(request, secret)
    return false if request.blank? || secret.blank?

    signature = request.headers["X-Webhook-Bullet-Train-Signature"]
    timestamp = request.headers["X-Webhook-Bullet-Train-Timestamp"]
    payload = request.raw_post

    return false if signature.blank? || timestamp.blank?

    verify(payload, signature, timestamp, secret)
  end
end
