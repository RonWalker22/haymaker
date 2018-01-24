class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :username
      t.money :cash, default: 100_000
      t.numeric :bitcoin, default: 0
      t.integer :rank, default: -1
      t.string :email

      t.timestamps
    end
  end
end
