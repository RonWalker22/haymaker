class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets do |t|
      t.string  :coin_type, null: false
      t.numeric :total_quantity,
                  precision:1000,
                  scale: 8,
                  default: 0,
                  null: false
      t.numeric :reserve_quantity,
                  precision:1000,
                  scale: 8,
                  default: 0,
                  null: false
      t.string :public_key, null: false
      t.references :league_user
      t.references :exchange
      t.timestamps
    end
    add_index :wallets,
              :public_key,
              unique: true
    add_index :wallets,
              [:coin_type, :exchange_id, :league_user_id],
              unique: true,
              name: 'unique_wallet'
  end
end
