require "cf"

# ClickFunnels client using the official clickfunnels-ruby-sdk
class ClickFunnels
  attr_reader :workspace_id, :subdomain, :api_key

  def initialize(api_key: nil, workspace_id: nil, subdomain: nil)
    # TODO: Only API secret should be env var. The others are configs.
    @workspace_id = workspace_id || ENV["CLICK_FUNNELS_WORKSPACE_ID"]
    @api_key = api_key || ENV["CLICK_FUNNELS_API_KEY"]
    @subdomain = subdomain || ENV["CLICK_FUNNELS_WORKSPACE_SUBDOMAIN"]

    raise ArgumentError, "ClickFunnels workspace_id is required" unless @workspace_id
    raise ArgumentError, "ClickFunnels subdomain is required" unless @subdomain
    raise ArgumentError, "ClickFunnels api_key is required" unless @api_key

    # TODO: This should happen in an initializer.
    configure_sdk
  end

  # List contacts with optional email filter
  # https://developers.myclickfunnels.com/reference/listcontacts
  #
  # @param email_address [String] Optional email address to filter contacts
  # @return [Array] Array of contact hashes from ClickFunnels API
  def list_contacts(email_address: nil)
    params = {}

    if email_address
      # Try different filter format based on the SDK documentation
      params[:filter] = {email_address: email_address}
    end

    params[:workspace_id] = workspace_id

    response = CF::Workspaces::Contact.list(params)

    # TODO: The SDK should return indifferent access hashes directly.
    Array(response).map { |item| item.to_h.with_indifferent_access }
  rescue => e
    Rails.logger.error("Error listing contacts: #{e.class} - #{e.message}") if defined?(Rails)
    []
  end

  # Find a contact by email address
  # @param email_address [String] Email address to find contact
  # @return [Hash, nil] Contact data or nil if not found
  def find_contact_by_email(email_address)
    contacts = list_contacts(email_address: email_address)

    if contacts.is_a?(Array) && !contacts.empty?
      contacts.first.to_h.with_indifferent_access
    end
  rescue => e
    Rails.logger.warn("Error finding contact by email: #{e.class} - #{e.message}") if defined?(Rails)
    nil
  end

  # Create a tag for a contact
  # https://developers.myclickfunnels.com/reference/createcontactsappliedtags
  #
  # @param contact_id [String] ID of the contact to tag
  # @param tag_id [String] ID of the tag to apply (defaults to power user tag 328935)
  # @return [Hash] Response from ClickFunnels API
  def create_contact_tag(contact_id, tag_id: "328935")
    response = CF::Contacts::AppliedTag.create(
      contact_id: contact_id,
      tag_id: tag_id
    )

    # Convert OpenStruct response to hash with string keys for compatibility
    # TODO: The SDK should return indifferent access hashes directly.
    response.to_h.with_indifferent_access
  rescue => e
    Rails.logger.error("Error creating contact tag: #{e.class} - #{e.message}") if defined?(Rails)
    {"error" => e.message}
  end

  # Mark a user as a power user
  # @param email_address [String] Email address of the user to mark as power user
  # @return [Boolean] True if successful, false otherwise
  #
  # FIXME: Any errors happening here and in the callstack bewow are unexpected and
  #        should be sent to the error tracker.
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
      raise "Failed to mark user as power user: #{response["error"]}"
    end

    # TODO: The SDK should return indifferent access hashes directly.
    response.to_h.with_indifferent_access
  end

  def base_url
    "https://#{subdomain}.myclickfunnels.com"
  end

  private

  def configure_sdk
    CF.configure do |config|
      config.subdomain = subdomain
      config.api_token = api_key
      config.workspace_id = workspace_id
      config.debug = Rails.env.development? if defined?(Rails)
    end
  end
end
