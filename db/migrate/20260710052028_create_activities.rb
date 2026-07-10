class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.string :subject_type
      t.integer :subject_id
      t.text :metadata

      t.timestamps
    end
  end
end
