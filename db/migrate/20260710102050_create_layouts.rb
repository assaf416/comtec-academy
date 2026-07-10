class CreateLayouts < ActiveRecord::Migration[8.1]
  def change
    create_table :layouts do |t|
      t.string :key
      t.string :name
      t.string :direction
      t.integer :kind
      t.text :css
      t.string :description

      t.timestamps
    end
    add_index :layouts, :key, unique: true
  end
end
