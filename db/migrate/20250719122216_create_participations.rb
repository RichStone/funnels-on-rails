class CreateParticipations < ActiveRecord::Migration[8.0]
  def change
    create_table :participations do |t|
      t.references :rails_builder, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :left_at
      t.text :left_reason

      t.timestamps
    end
  end
end
