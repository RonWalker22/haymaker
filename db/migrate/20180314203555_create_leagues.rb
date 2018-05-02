class CreateLeagues < ActiveRecord::Migration[5.1]
  def change
    create_table :leagues do |t|
      t.string :name,                                               null: false
      t.string :entry_fee,              default: 'FREE',            null: false
      t.references :user
      t.datetime :start_date,          default: DateTime.now,       null: false
      t.datetime :end_date,            default: 1.month.from_now,   null: false
      t.integer :rounds,               default: 1,                  null: false
      t.timestamps
    end
  end
end
