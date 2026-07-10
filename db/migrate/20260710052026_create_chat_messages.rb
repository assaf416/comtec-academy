class CreateChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :episode, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.text :body, null: false

      t.timestamps
    end
  end
end
