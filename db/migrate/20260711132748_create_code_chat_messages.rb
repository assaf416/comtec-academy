class CreateCodeChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :code_chat_messages do |t|
      t.references :subject, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.text :body, null: false

      t.timestamps
    end
  end
end
