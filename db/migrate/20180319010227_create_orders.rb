class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :base_currency,
                    index: true,
                    null: false,
                    foreign_key: {to_table: :wallets}
      t.references :quote_currency,
                    index: true,
                    null: false,
                    foreign_key: {to_table: :wallets}
      t.boolean :open,
                default: true,
                null: false
      t.decimal :size,
                null: false
      t.decimal :reserve_size,
                default:0.00,
                null: false
      t.decimal :price,
                null: false
      t.decimal :fee,
                default: 0.00,
                null: false
      t.string :product,
                null: false
      t.string :side,
                default: 'buy',
                null:false
      t.string :kind,
                default: 'market',
                null:false
      t.timestamps
    end
    add_index :orders,
              [:base_currency_id, :quote_currency_id, :id],
              unique: true
  end
end
