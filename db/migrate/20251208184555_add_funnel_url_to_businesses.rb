class AddFunnelUrlToBusinesses < ActiveRecord::Migration[8.0]
  def change
    add_column :businesses, :funnel_url, :string
  end
end
