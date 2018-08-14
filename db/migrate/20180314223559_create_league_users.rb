class CreateLeagueUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :league_users do |t|
      t.references :league,                         null: false
      t.references :user,                           null: false
      t.boolean :ready,             default: false, null: false
      t.boolean :set_up,            default: false, null: false
      t.boolean :alive,             default: true,  null: false
      t.integer :rank,              default: 0,    null: false
      t.numeric :btce,              default: 1,     null: false
      t.numeric :points,            default: 0,     null: false
      t.numeric :leverage_points,   default: 0,     null: false
      t.boolean :champ,             default: false, null: false
      t.integer :blocks,            default: 0,     null: false
      t.boolean :shield,            default: false, null: false

      t.timestamps
    end
    add_index :league_users,
              [:league_id, :user_id],
              unique: true
  end
end
