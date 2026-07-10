class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.text :details
      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end
