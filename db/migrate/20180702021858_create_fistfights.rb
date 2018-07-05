class CreateFistfights < ActiveRecord::Migration[5.1]
  def change
    create_table :fistfights do |t|
      t.references :league, null: false
      t.references :attacker,
                    index: true,
                    foreign_key: {to_table: :users},
                    null: false
      t.references :defender,
                    index: true,
                    foreign_key: {to_table: :users},
                    null: false
      t.integer    :round,
                   null: false
      t.boolean    :active,
                    default: true,
                    null: false
      t.timestamps
    end
    add_index :fistfights,
              [:defender_id, :attacker_id],
              unique: true
    add_index :fistfights,
              [:round, :attacker_id],
              unique: true
    add_index :fistfights,
              [:round, :defender_id],
              unique: true
  end
end
