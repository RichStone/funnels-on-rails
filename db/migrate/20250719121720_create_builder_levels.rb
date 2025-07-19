class CreateBuilderLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :builder_levels do |t|
      t.string :name
      t.text :description
      t.string :image

      t.timestamps
    end
  end
end
