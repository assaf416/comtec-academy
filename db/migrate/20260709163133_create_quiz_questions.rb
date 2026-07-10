class CreateQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_questions do |t|
      t.references :episode, null: false, foreign_key: true
      t.text :prompt
      t.text :choices
      t.string :correct_choice

      t.timestamps
    end
  end
end
