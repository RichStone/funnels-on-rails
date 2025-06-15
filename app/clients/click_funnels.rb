# Co-vibed with Junie - This is not a pretty API client, but it will be
# reworked once we have the Speakeasy auto-generated SDK client.
class ClickFunnels
  attr_reader :workspace_id, :subdomain, :api_key

  def initialize(api_key: nil, workspace_id: nil, subdomain: nil)
    # TODO: Only API secret should be env var. The others are configs. CLICK_FUNNELS_SUBDOMAIN is wrongly named in .env.
    @workspace_id = workspace_id || ENV["CLICK_FUNNELS_WORKSPACE_ID"]
    @api_key = api_key || ENV["CLICK_FUNNELS_API_KEY"]
    @subdomain = subdomain || ENV["CLICK_FUNNELS_SUBDOMAIN"]

    raise ArgumentError, "ClickFunnels workspace_id is required" unless @workspace_id
    raise ArgumentError, "ClickFunnels subdomain is required" unless @subdomain
    raise ArgumentError, "ClickFunnels api_key is required" unless @api_key
  end

  # List contacts with optional email filter
  # https://developers.myclickfunnels.com/reference/listcontacts
  #
  # @param email_address [String] Optional email address to filter contacts
  # @return [Hash] Response from ClickFunnels API
  def list_contacts(email_address: nil)
    path = "/api/v2/workspaces/#{workspace_id}/contacts"

    params = {}
    params["filter[email_address]"] = email_address if email_address

    response = connection.get(path, params)

    JSON.parse(response.body)
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

    if response.is_a?(Array) && !response.empty?
      response.first
    else
      nil
    end
  end

  # Create a tag for a contact
  # https://developers.myclickfunnels.com/reference/createcontactsappliedtags
  #
  # @param contact_id [String] ID of the contact to tag
  # @param tag_id [String] ID of the tag to apply (defaults to power user tag 328935)
  # @return [Hash] Response from ClickFunnels API
  def create_contact_tag(contact_id, tag_id: "328935")
    path = "/api/v2/contacts/#{contact_id}/applied_tags"

    payload = {
      contacts_applied_tag: {
        contact_id: contact_id,
        tag_id: tag_id
      }
    }

    response = connection.post(path) do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = payload.to_json
    end

    JSON.parse(response.body)
  end

  # Mark a user as a power user
  # @param email_address [String] Email address of the user to mark as power user
  # @return [Boolean] True if successful, false otherwise
  def mark_as_power_user(email_address)
    contact = find_contact_by_email(email_address)
    # TODO: This is an inconsistency between the BusinessOS and app, worth sending to the error tracker.
    unless contact
      Rails.logger.error("Contact not found to mark as power user for email: #{email_address}")
      return false
    end

    contact_id = contact["id"]
    response = create_contact_tag(contact_id)

    if response.is_a?(Hash) && response["error"]
      Rails.logger.error("Error marking user as power user: #{response["error"]}")
      return false
    end

    !response.nil? && response.key?("data")
  end

  def base_url
    "https://#{subdomain}.myclickfunnels.com"
  end

  private

  def connection
    @connection ||= Faraday.new(url: base_url) do |conn|
      conn.headers["Authorization"] = "Bearer #{api_key}"
      conn.headers["Accept"] = "application/json"
      conn.headers["User-Agent"] = "RichStoneIO"
      conn.adapter Faraday.default_adapter
    end
  end
end
