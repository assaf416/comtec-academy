class CreateSlideAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :slide_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :slide, null: false, foreign_key: true
      t.text :answer

      t.timestamps
    end
    add_index :slide_answers, [ :user_id, :slide_id ], unique: true
  end
end
