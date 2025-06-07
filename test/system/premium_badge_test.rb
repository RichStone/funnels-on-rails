require "application_system_test_case"

class PremiumBadgeTest < ApplicationSystemTestCase
  setup do
    @premium_user = create :onboarded_user, first_name: "Premium", last_name: "User", subscription_status: User::SUBSCRIPTION_STATUSES[:premium]
    @regular_user = create :onboarded_user, first_name: "Regular", last_name: "User"
  end

  device_test "premium user sees premium badge" do
    login_as(@premium_user, scope: :user)
    visit account_team_path(@premium_user.current_team)

    # Check for premium badge
    assert_selector "h3", text: "This is your Premium badge ⭐️"
    assert_text "Shoot Rich an email to chat about your most important question in the 1-on-1 consultation"
    assert_text "hey@richsteinmetz.com"
    assert_text "You can cancel here:"
    assert_selector "a", text: "https://www.funnelsonrails.com/contacts/sign_in"
  end

  device_test "regular user does not see premium badge" do
    login_as(@regular_user, scope: :user)
    visit account_team_path(@regular_user.current_team)

    # Check that premium badge is not displayed
    assert_no_selector "h3", text: "This is your Premium badge ⭐️"
    assert_no_text "Shoot Rich an email to chat about your most important question in the 1-on-1 consultation"
  end
end
