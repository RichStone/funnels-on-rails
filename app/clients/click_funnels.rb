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
    path = "/workspaces/#{workspace_id}/contacts"

    params = {}
    params["filter[email_address]"] = email_address if email_address

    response = connection.get(path, params)
    handle_response(response)
  end

  # Find a contact by email address
  # @param email_address [String] Email address to find contact
  # @return [Hash, nil] Contact data or nil if not found
  def find_contact_by_email(email_address)
    response = list_contacts(email_address: email_address)

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
    path = "/workspaces/#{workspace_id}/contacts/applied_tags"

    payload = {
      data: {
        type: "contacts_applied_tags",
        attributes: {
          contact_id: contact_id,
          tag_id: tag_id
        }
      }
    }

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

    !response.nil? && response.key?("data")
  end

  def base_url
    "https://#{subdomain}.myclickfunnels.com/api/v2"
  end

  private

  def connection
    @connection ||= Faraday.new(url: base_url) do |conn|
      conn.headers["Authorization"] = "Bearer #{api_key}"
      conn.headers["Accept"] = "application/json"
      conn.adapter Faraday.default_adapter
    end
  end

  def handle_response(response)
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
          # If it doesn't look like JSON, provide a helpful error message
          preview = body.slice(0, 100)
          raise JSON::ParserError, "Response is not valid JSON. Received: #{preview}..."
        end
      rescue JSON::ParserError => e
        raise "ClickFunnels#handle_response: #{e.message}"
      end
    when 404
      nil
    else
      raise "ClickFunnels API Error: #{response.status} - #{response.body}"
    end
  end
end
