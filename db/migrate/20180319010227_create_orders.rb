class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :wallet, null:false
      t.boolean :open, default: true, null: false
      t.decimal :size, null: false
      t.decimal :price, null: false
      t.decimal :fee, default: 0.00, null: false
      t.string :product, null: false
      t.boolean :buy, null:false
      t.timestamps
    end
  end
end
