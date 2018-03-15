class CreateLeaguePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :league_players do |t|
      t.references :league
      t.references :player

      t.timestamps
    end
    add_index :league_players, 
              [:league_id, :player_id], 
              unique: true
  end
end
