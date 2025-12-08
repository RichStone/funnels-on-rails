class AddAppUrlToBusinesses < ActiveRecord::Migration[8.0]
  def change
    add_column :businesses, :app_url, :string
  end
end
