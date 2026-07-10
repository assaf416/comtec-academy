class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :project, null: false, foreign_key: true
      t.integer :doc_type, null: false
      t.string :title
      t.text :content

      t.timestamps
    end
    # One current document per (project, type) — enforces upsert-by-type.
    add_index :documents, [ :project_id, :doc_type ], unique: true
  end
end
