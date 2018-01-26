class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_digest
      t.string :password_confirmation

      t.money :cash, default: 100_000
      t.numeric :bitcoin, default: 0
      t.integer :rank, default: -1

      t.timestamps
    end
  end
end
