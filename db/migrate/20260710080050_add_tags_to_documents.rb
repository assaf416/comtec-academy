class AddTagsToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :tags, :string
  end
end
