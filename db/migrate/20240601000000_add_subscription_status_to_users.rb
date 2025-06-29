class AddSubscriptionStatusToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :subscription_status, :string, default: nil
  end
end
