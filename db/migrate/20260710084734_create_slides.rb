class CreateSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :slides do |t|
      t.references :presentation, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.text :content
      t.text :notes
      t.float :duration

      t.timestamps
    end
  end
end
