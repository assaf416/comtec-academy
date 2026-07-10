class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      # Null until the invited user activates and chooses a password.
      t.string :password_digest
      t.string :name
      t.integer :role, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :invited_at
      t.datetime :activated_at

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
