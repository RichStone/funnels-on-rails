require "test_helper"
require_relative "../../app/clients/click_funnels"

class WardenCurrentAttributesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  # Helper method to simulate the Warden after_authentication hook
  def simulate_after_authentication(user)
    # This is the same code as in the Warden hook
    Current.user = user

    # Mark user as power user in ClickFunnels if this is their second login
    if user.sign_in_count == 2
      MarkPowerUserJob.perform_later(user.email)
    end
  end

  test "enqueues job to mark user as power user on second login" do
    # Create a user with sign_in_count = 1 (first login)
    user = create(:user, sign_in_count: 1)

    # Expect the job to be enqueued with the user's email
    assert_enqueued_with(job: MarkPowerUserJob, args: [user.email]) do
      # Simulate Warden authentication hook
      user.sign_in_count = 2
      simulate_after_authentication(user)
    end
  end

  test "does not enqueue job on first login" do
    # Create a user with sign_in_count = 0 (no logins yet)
    user = create(:user, sign_in_count: 0)

    # Expect no jobs to be enqueued
    assert_no_enqueued_jobs do
      # Simulate Warden authentication hook
      user.sign_in_count = 1
      simulate_after_authentication(user)
    end
  end

  test "does not enqueue job on third or later logins" do
    # Create a user with sign_in_count = 2 (already logged in twice)
    user = create(:user, sign_in_count: 2)

    # Expect no jobs to be enqueued
    assert_no_enqueued_jobs do
      # Simulate Warden authentication hook
      user.sign_in_count = 3
      simulate_after_authentication(user)
    end
  end

end
