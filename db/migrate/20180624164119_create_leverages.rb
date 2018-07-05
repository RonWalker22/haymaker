class CreateLeverages < ActiveRecord::Migration[5.1]
  def change
    create_table :leverages do |t|
      t.string  :kind,        null: false
      t.decimal :size,        null: false
      t.decimal :liquidation, null: false
      t.timestamps
    end
  end
end
