class CreateLeagues < ActiveRecord::Migration[5.1]
  def change
    create_table :leagues do |t|
      t.string :name,                                           null: false
      t.string :entry_fee,          default: 'FREE',            null: false
      t.string :prize,              default: 'Bragging Rights', null: false
      t.decimal :starting_balance,  default: 1.0,               null: false
      t.string :starting_exchange,  default: 'any',             null: false
      t.boolean :balance_revivable, default: false,             null: false
      t.boolean :exchange_fees,     default: true,              null: false
      t.boolean :exchange_risk,     default: true,              null: false
      t.references :commissioner,
                    index: true,
                    foreign_key: {to_table: :users},
                    null: false
      t.datetime :start_date,                                   null: false
      t.datetime :end_date,                                     null: false
      t.integer :rounds,            default: 1,                 null: false
      t.timestamps
    end
  end
end
