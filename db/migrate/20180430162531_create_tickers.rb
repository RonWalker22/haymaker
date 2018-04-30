class CreateTickers < ActiveRecord::Migration[5.1]
  def change
    create_table :tickers do |t|
      t.references :exchange, null: false
      t.decimal :price, default: 0.00, null: false
      t.string :pair, null: false

      t.timestamps
    end
    add_index :tickers,
              [:pair, :exchange_id],
              unique: true
  end
end
