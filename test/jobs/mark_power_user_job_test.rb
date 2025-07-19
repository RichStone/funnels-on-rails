# frozen_string_literal: true

require "test_helper"
require_relative "../../app/clients/click_funnels"

class MarkPowerUserJobTest < ActiveJob::TestCase
  test "marks user as power user" do
    email = "test@example.com"

    # Mock the ClickFunnels client
    mock_client = mock("click_funnels_client")
    ClickFunnels.expects(:new).returns(mock_client)

    # Expect mark_as_power_user to be called with the email
    mock_client.expects(:mark_as_power_user).with(email).once

    # Perform the job
    MarkPowerUserJob.perform_now(email)
  end

  test "handles errors from ClickFunnels client" do
    email = "test@example.com"

    # Mock the ClickFunnels client to raise an error
    mock_client = mock("click_funnels_client")
    ClickFunnels.expects(:new).returns(mock_client)
    mock_client.expects(:mark_as_power_user).with(email).raises(StandardError.new("API Error"))

    # Stub Rails.logger to allow any error calls
    Rails.logger.stubs(:error)

    # Perform the job - should raise an error
    assert_raises(StandardError) do
      MarkPowerUserJob.perform_now(email)
    end
  end
end
