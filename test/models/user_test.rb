require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new(email: "jane@bullettrain.co")
  end

  test "details_provided should be true when details are provided" do
    @user = FactoryBot.create :onboarded_user, first_name: "a", last_name: "b"
    assert @user.details_provided?
  end

  test "details_provided should be false when details aren't provided" do
    @user = FactoryBot.create :user, first_name: "a", last_name: nil
    assert_equal @user.details_provided?, false
  end

  test "offboard_customer sets subscription_status to nil" do
    @user = FactoryBot.create :user, subscription_status: User::SUBSCRIPTION_STATUSES[:premium]
    assert_equal User::SUBSCRIPTION_STATUSES[:premium], @user.subscription_status

    @user.offboard_customer

    assert_nil @user.subscription_status
  end

  test "offboard_customer works when subscription_status is already nil" do
    @user = FactoryBot.create :user, subscription_status: nil
    assert_nil @user.subscription_status

    @user.offboard_customer

    assert_nil @user.subscription_status
  end
end
