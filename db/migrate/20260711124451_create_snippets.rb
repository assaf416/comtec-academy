class CreateSnippets < ActiveRecord::Migration[8.1]
  def change
    create_table :snippets do |t|
      t.string :title, null: false
      t.string :language, null: false, default: "other"
      t.text :body, null: false
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.references :project, null: true, foreign_key: true
      t.integer :visibility, null: false, default: 0

      t.timestamps
    end
    add_index :snippets, :language
  end
end
