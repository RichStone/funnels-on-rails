# frozen_string_literal: true

class MarkPowerUserJob < ApplicationJob
  queue_as :default

  # Mark a user as a power user in ClickFunnels
  # @param email [String] Email address of the user to mark as power user
  def perform(email)
    click_funnels_client = ClickFunnels.new
    click_funnels_client.mark_as_power_user(email)
  rescue => e
    Rails.logger.error("Failed to mark user as power user in ClickFunnels: #{e.class} - #{e.message}")
    raise e
  end
end
