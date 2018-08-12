class CreateMarkets < ActiveRecord::Migration[5.1]
  def change
    create_table :markets do |t|
      t.string  :name,  null:false
      t.decimal :cap, default: 1, null:false
      t.timestamps
    end
  end
end
