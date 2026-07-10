class CreateMarkdownDocs < ActiveRecord::Migration[8.1]
  def change
    create_table :markdown_docs do |t|
      t.references :episode, null: false, foreign_key: true
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
