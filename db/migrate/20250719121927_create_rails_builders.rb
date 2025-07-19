class CreateRailsBuilders < ActiveRecord::Migration[8.0]
  def change
    create_table :rails_builders do |t|
      t.references :team, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.references :builder_level, null: true, foreign_key: true

      t.timestamps
    end
  end
end
