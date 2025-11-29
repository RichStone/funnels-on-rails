#!/usr/bin/env ruby


# ⚠️ This is a tested but vibe-coded script.
# ⚠️ Please use it with caution and at your own risk.


# ClickFunnels Contact Import Script
# ==================================
# This script demonstrates best practices for importing contacts via API:
# - Reading from a CSV file
# - Handling rate limits gracefully (429 errors)
# - Spacing out requests to avoid hitting limits
# - Error handling with helpful output
#
# Run with: ruby import_contact_import_script.rb

require "csv"
require "net/http"
require "json"
require "uri"
require "openssl"

# =============================================================================
# CONFIGURATION
# =============================================================================

API_KEY = ENV["TESTONLY_WORKSPACCE_API_KEY"]
WORKSPACE_ID = ENV["TESTONLY_WORKSPACCE_ID"]
BASE_URL = "https://testonly.myclickfunnels.com/api/v2"

# Timing configuration
DEFAULT_DELAY_SECONDS = 1      # Wait 1 second between each request
RATE_LIMIT_DELAY_SECONDS = 30  # Wait 30 seconds if we hit a rate limit (429)
MAX_RETRIES = 3                # Maximum number of retries for rate limits

# =============================================================================
# PRE-CLEANING NOTES
# =============================================================================
#
# Before running an import, you should clean your data:
#
# 1. Email validation:
#    - Check for valid email format (contains @ and domain)
#    - Remove duplicates
#    - Trim whitespace
#    - Convert to lowercase
#    - Run this through an email validation service if possible (API)
#
# 2. Name fields:
#    - Trim whitespace
#    - Capitalize properly (e.g., "john" -> "John")
#    - Remove special characters if not needed
#
# 3. General:
#    - Remove completely empty rows
#    - Check for encoding issues (UTF-8)
#    - Validate required fields are present
#
# Example pre-cleaning code:
#
#   def clean_email(email)
#     return nil if email.nil?
#     email.strip.downcase
#   end
#
#   def valid_email?(email)
#     email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
#   end
#
#   def clean_name(name)
#     return "" if name.nil?
#     name.strip.capitalize
#   end
#
# =============================================================================

# =============================================================================
# IMPORT LOGIC
# =============================================================================

def upsert_contact(email:, first_name:, last_name:)
  # Using the upsert endpoint - creates if new, updates if email exists
  # Docs: https://developers.myclickfunnels.com/reference/upsertcontacts
  uri = URI("#{BASE_URL}/workspaces/#{WORKSPACE_ID}/contacts/upsert")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Skip CRL check that fails on Ruby 3.4

  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{API_KEY}"
  request["Content-Type"] = "application/json"
  request["User-Agent"] = "FunnelsOnRails"

  body = {
    contact: {
      email_address: email,
      first_name: first_name,
      last_name: last_name,
      custom_attributes: {
        imported: "30th of November 2025"
      }
    }
  }

  request.body = body.to_json

  http.request(request)
end

def import_contacts(csv_path)
  puts "=" * 60
  puts "Starting Contact Import"
  puts "=" * 60
  puts ""

  # Check if API key is set
  if API_KEY.nil? || API_KEY.empty?
    puts "ERROR: API key not found!"
    puts "Please set the TESTONLY_WORKSPACCE_API_KEY environment variable."
    puts ""
    puts "Example: export TESTONLY_WORKSPACCE_API_KEY='your-api-key-here'"
    return
  end

  # Read the CSV file
  contacts = CSV.read(csv_path, headers: true)
  total_contacts = contacts.size

  puts "Found #{total_contacts} contacts to import"
  puts ""

  # Track results
  successful = 0
  failed = 0
  failed_contacts = []

  contacts.each_with_index do |row, index|
    contact_number = index + 1
    email = row["email"]
    first_name = row["first_name"]
    last_name = row["last_name"]

    puts "[#{contact_number}/#{total_contacts}] Importing: #{email}"

    # Retry loop for handling rate limits
    retries = 0
    success = false

    while retries <= MAX_RETRIES && !success
      begin
        response = upsert_contact(
          email: email,
          first_name: first_name,
          last_name: last_name
        )

        case response.code.to_i
        when 200
          # 200 = Updated existing contact
          puts "  -> SUCCESS: Contact updated"
          successful += 1
          success = true

        when 201
          # 201 = Created new contact
          puts "  -> SUCCESS: Contact created"
          successful += 1
          success = true

        when 429
          # Rate limit hit - wait and retry
          retries += 1
          if retries <= MAX_RETRIES
            puts "  -> RATE LIMITED: Waiting #{RATE_LIMIT_DELAY_SECONDS} seconds... (retry #{retries}/#{MAX_RETRIES})"
            sleep(RATE_LIMIT_DELAY_SECONDS)
          else
            puts "  -> FAILED: Rate limit exceeded after #{MAX_RETRIES} retries"
            failed += 1
            failed_contacts << {email: email, error: "Rate limit exceeded after #{MAX_RETRIES} retries"}
          end

        when 400, 422
          # Validation error (like invalid email) - no point retrying
          error_message = begin
            JSON.parse(response.body)["message"] || response.body
          rescue
            response.body
          end
          puts "  -> VALIDATION ERROR: #{error_message}"
          failed += 1
          failed_contacts << {email: email, error: error_message}
          success = true # Exit loop, but it's a failure

        else
          # Other error
          puts "  -> ERROR (#{response.code}): #{response.body}"
          failed += 1
          failed_contacts << {email: email, error: response.body}
          success = true # Exit loop, but it's a failure
        end

      rescue StandardError => e
        # Catch any unexpected errors (network issues, etc.)
        puts "  -> EXCEPTION: #{e.class} - #{e.message}"
        failed += 1
        failed_contacts << {email: email, error: e.message}
        success = true # Exit loop, but it's a failure
      end
    end

    # Space out requests - wait before the next one
    puts "  -> Waiting #{DEFAULT_DELAY_SECONDS} second(s) before next request..."
    sleep(DEFAULT_DELAY_SECONDS)

    puts ""
  end

  # Print summary
  puts "=" * 60
  puts "Import Complete!"
  puts "=" * 60
  puts ""
  puts "Total contacts:  #{total_contacts}"
  puts "Successful:      #{successful}"
  puts "Failed:          #{failed}"
  puts ""

  if failed_contacts.any?
    puts "Failed Contacts:"
    puts "-" * 40
    failed_contacts.each do |contact|
      puts "  Email: #{contact[:email]}"
      puts "  Error: #{contact[:error]}"
      puts ""
    end
  end
end

# =============================================================================
# TEST A SINGLE CONTACT
# =============================================================================

def test_single_contact
  puts "=" * 60
  puts "Testing Single Contact Creation"
  puts "=" * 60
  puts ""

  if API_KEY.nil? || API_KEY.empty?
    puts "ERROR: API key not found!"
    puts "Please set the TESTONLY_WORKSPACCE_API_KEY environment variable."
    return
  end

  # Test with a single fake contact
  response = upsert_contact(
    email: "testo-#{rand(10)}.import@faketests.com",
    first_name: "Test",
    last_name: "Import"
  )

  puts "Response code: #{response.code}"
  puts "Response body: #{response.body}"
  puts ""

  case response.code.to_i
  when 200
    puts "SUCCESS: Contact updated"
  when 201
    puts "SUCCESS: Contact created"
  else
    puts "FAILED: Check the response above"
  end
end

# =============================================================================
# RUN THE IMPORT
# =============================================================================

# Usage:
#   ruby import_contact_import_script.rb          # Run full import from CSV
#   ruby import_contact_import_script.rb --test   # Test with a single contact

if ARGV.include?("--test")
  test_single_contact
else
  # Get the directory where this script is located
  script_dir = File.dirname(__FILE__)
  csv_path = File.join(script_dir, "contacts.csv")

  if File.exist?(csv_path)
    import_contacts(csv_path)
  else
    puts "ERROR: CSV file not found at #{csv_path}"
    puts "Make sure contacts.csv is in the same directory as this script."
  end
end
