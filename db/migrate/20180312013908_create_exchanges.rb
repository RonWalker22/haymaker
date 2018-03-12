class CreateExchanges < ActiveRecord::Migration[5.1]
  def change
    create_table :exchanges do |t|
      t.string :name, null: false
      t.string :status, null: false, default: 'online'
      t.numeric :maker_fee, null: false, default: 0
      t.numeric :taker_fee, null: false, default: 0
      t.numeric :withdrawal_fee, null: false, default: 0
      t.numeric :deposit_fee, null: false, default: 0

      t.timestamps
    end
  end
end
