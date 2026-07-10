class AddLibraryFieldsToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :source, :integer, null: false, default: 0
    add_column :documents, :views_count, :integer, null: false, default: 0
    # Uploaded library documents are standalone (no project).
    change_column_null :documents, :project_id, true
  end
end
