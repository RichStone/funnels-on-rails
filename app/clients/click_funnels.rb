class ClickFunnels
  attr_reader :workspace_id, :subdomain, :api_key

  def initialize(api_key: nil, workspace_id: nil, subdomain: nil)
    @workspace_id = workspace_id || ENV["CLICK_FUNNELS_WORKSPACE_ID"]
    @api_key = api_key || ENV["CLICK_FUNNELS_API_KEY"]
    @subdomain = subdomain || ENV["CLICK_FUNNELS_SUBDOMAIN"]

    raise ArgumentError, "ClickFunnels workspace_id is required" unless @workspace_id
    raise ArgumentError, "ClickFunnels subdomain is required" unless @subdomain
    raise ArgumentError, "ClickFunnels api_key is required" unless @api_key
  end

  # List contacts with optional email filter
  # @param email_address [String] Optional email address to filter contacts
  # @return [Hash] Response from ClickFunnels API
  def list_contacts(email_address: nil)
    path = "/api/v2/workspaces/#{workspace_id}/contacts"

    params = {}
    params["filter[email_address]"] = email_address if email_address

    log_request("GET", path, params: params)
    response = connection.get(path, params)
    handle_response(response)
  end

  # Find a contact by email address
  # @param email_address [String] Email address to find contact
  # @return [Hash, nil] Contact data or nil if not found
  def find_contact_by_email(email_address)
    response = list_contacts(email_address: email_address)

    # Check if we got an error response
    if response.is_a?(Hash) && response["error"]
      Rails.logger.warn("Error finding contact by email: #{response["message"]}") if defined?(Rails)
      return nil
    end

    if response["data"].is_a?(Array) && !response["data"].empty?
      response["data"].first
    else
      nil
    end
  end

  # Create a tag for a contact
  # @param contact_id [String] ID of the contact to tag
  # @param tag_id [String] ID of the tag to apply (defaults to power user tag 328935)
  # @return [Hash] Response from ClickFunnels API
  def create_contact_tag(contact_id, tag_id: "328935")
    path = "/api/v2/workspaces/#{workspace_id}/contacts/applied_tags"

    payload = {
      data: {
        type: "contacts_applied_tags",
        attributes: {
          contact_id: contact_id,
          tag_id: tag_id
        }
      }
    }

    log_request("POST", path, payload: payload)
    response = connection.post(path) do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = payload.to_json
    end

    handle_response(response)
  end

  # Mark a user as a power user
  # @param email_address [String] Email address of the user to mark as power user
  # @return [Boolean] True if successful, false otherwise
  def mark_as_power_user(email_address)
    contact = find_contact_by_email(email_address)
    return false unless contact

    contact_id = contact["id"]
    response = create_contact_tag(contact_id)

    # Check if we got an error response
    if response.is_a?(Hash) && response["error"]
      Rails.logger.warn("Error marking user as power user: #{response["message"]}") if defined?(Rails)
      return false
    end

    !response.nil? && response.key?("data")
  end

  def base_url
    "https://#{subdomain}.myclickfunnels.com"
  end

  private

  def log_request(method, path, params: nil, payload: nil)
    return unless defined?(Rails)

    full_url = "#{base_url}#{path}"
    full_url += "?#{params.to_query}" if params.present?

    headers = {
      "Authorization" => "Bearer #{api_key}",
      "Accept" => "application/json",
      "User-Agent" => "RichStoneIO"
    }
    headers["Content-Type"] = "application/json" if payload.present?

    log_message = "ClickFunnels API Request: #{method} #{full_url}"
    log_message += "\nHeaders: #{headers.inspect}"
    log_message += "\nPayload: #{payload.inspect}" if payload.present?

    Rails.logger.info(log_message)
  end

  def connection
    @connection ||= Faraday.new(url: base_url) do |conn|
      conn.headers["Authorization"] = "Bearer #{api_key}"
      conn.headers["Accept"] = "application/json"
      conn.headers["User-Agent"] = "RichStoneIO"
      conn.adapter Faraday.default_adapter
    end
  end

  def log_response(response, is_error: false)
    return unless defined?(Rails)

    log_level = is_error ? :error : :info

    log_message = "ClickFunnels API Response: #{response.status}"
    log_message += "\nHeaders: #{response.headers.inspect}"

    # Log the full response body with proper encoding handling
    begin
      # First, try to force the encoding to UTF-8 and see if it's valid
      body_text = response.body.dup
      body_text.force_encoding('UTF-8')

      # If the forced encoding resulted in invalid UTF-8, try to encode with replacement
      unless body_text.valid_encoding?
        body_text = response.body.dup.force_encoding('ASCII-8BIT').encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      end

      log_message += "\nBody: #{body_text}"
      Rails.logger.send(log_level, log_message)
    rescue => e
      # If there's still an encoding error, log without the body
      Rails.logger.send(log_level, "ClickFunnels API Response: #{response.status} (Body logging failed due to encoding issues: #{e.message})")
      Rails.logger.send(log_level, "Headers: #{response.headers.inspect}")
    end
  end

  def handle_response(response)
    # Log all responses for debugging
    log_response(response, is_error: response.status >= 400)

    case response.status
    when 200..299
      begin
        # Check if response body looks like JSON before parsing
        body = response.body.strip
        if body.empty?
          {}
        elsif (body.start_with?('{') && body.end_with?('}')) || (body.start_with?('[') && body.end_with?(']'))
          JSON.parse(body)
        else
          # If it doesn't look like JSON, log and return a structured error response
          Rails.logger.error("ClickFunnels API returned non-JSON response. See response above (if available).") if defined?(Rails)

          # Return a structured error response that can be handled by the calling code
          {
            "error" => true,
            "error_type" => "non_json_response",
            "message" => "Response is not valid JSON",
            "preview" => body.slice(0, 100),
            "status" => response.status
          }
        end
      rescue JSON::ParserError => e
        # Log the error for debugging
        Rails.logger.error("ClickFunnels JSON parsing error: #{e.message}") if defined?(Rails)

        # Return a structured error response
        {
          "error" => true,
          "error_type" => "json_parse_error",
          "message" => e.message,
          "status" => response.status
        }
      end
    when 404
      nil
    else
      # Log the error for debugging (response is already logged above if available)
      Rails.logger.error("ClickFunnels API Error: #{response.status}. See response above (if available).") if defined?(Rails)

      # Return a structured error response
      {
        "error" => true,
        "error_type" => "api_error",
        "message" => "API Error: #{response.status}",
        "status" => response.status,
        "body" => response.body.to_s.slice(0, 200) # Include a preview of the response body
      }
    end
  end
end
