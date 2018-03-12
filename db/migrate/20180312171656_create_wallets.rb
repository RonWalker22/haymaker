class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets do |t|
      t.string  :coin_type, null: false
      t.numeric :coin_quantity, default: 0, null: false
      t.string :public_key, null: false

      t.references :player
      t.references :exchange
      t.timestamps
    end
    add_index :wallets, :public_key, unique: true
    add_index :wallets, [:coin_type, :player_id, :exchange_id], unique: true
  end
end
