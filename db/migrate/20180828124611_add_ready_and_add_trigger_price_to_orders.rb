class AddReadyAndAddTriggerPriceToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :ready, :boolean, default: false, null: false
    add_column :orders, :trigger_price, :decimal, default: 0, null: false
  end
end
