class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end
