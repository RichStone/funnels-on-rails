class User < ApplicationRecord
  include Users::Base
  include Roles::User
  # 🚅 add concerns above.

  SUBSCRIPTION_STATUSES = {
    regular: nil,
    premium: "premium"
  }.freeze

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def offboard_customer
    update!(subscription_status: nil)
  end

  # 🚅 add methods above.
end
