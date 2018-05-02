class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets do |t|
      t.string  :coin_type, null: false
      t.numeric :coin_quantity, default: 0, null: false
      t.string :public_key, null: false

      t.references :user
      t.references :exchange
      t.references :league

      t.timestamps
    end
    add_index :wallets,
              :public_key,
              unique: true
    add_index :wallets,
              [:coin_type, :user_id, :exchange_id, :league_id],
              unique: true,
              name: 'unique_wallet'
  end
end
