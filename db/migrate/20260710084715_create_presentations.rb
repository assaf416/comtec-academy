class CreatePresentations < ActiveRecord::Migration[8.1]
  def change
    create_table :presentations do |t|
      t.string :title, null: false
      t.text :description
      t.text :source_md
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
