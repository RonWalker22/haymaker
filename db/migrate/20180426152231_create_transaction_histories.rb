class CreateTransactionHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :transaction_histories do |t|
      t.references :wallet, null:false
      t.boolean :completed, default: true, null: false
      t.decimal :amount, null: false
      t.decimal :fee, default: 0.00, null: false
      t.string :address, null: false
      t.string :coin, null: false
      t.boolean :deposit_type, null:false
      t.timestamps
    end
  end
end
