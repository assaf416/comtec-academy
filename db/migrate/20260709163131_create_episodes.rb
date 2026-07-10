class CreateEpisodes < ActiveRecord::Migration[8.1]
  def change
    create_table :episodes do |t|
      t.references :course, null: false, foreign_key: true
      t.string :name
      t.string :title
      t.integer :kind, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.text :transcript
      t.string :movie_url
      t.string :audiobook_url

      t.timestamps
    end
  end
end
