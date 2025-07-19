class AddDetailsToRailsBuilders < ActiveRecord::Migration[8.0]
  def change
    add_column :rails_builders, :details, :jsonb
  end
end
