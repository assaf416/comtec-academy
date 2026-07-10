class AddLayoutAndQuizToSlides < ActiveRecord::Migration[8.1]
  def change
    add_reference :slides, :layout, null: true, foreign_key: true
    add_column :slides, :choices, :text
    add_column :slides, :correct_choice, :string
  end
end
