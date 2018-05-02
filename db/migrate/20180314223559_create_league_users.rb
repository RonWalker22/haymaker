class CreateLeagueUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :league_users do |t|
      t.references :league
      t.references :user

      t.timestamps
    end
    add_index :league_users,
              [:league_id, :user_id],
              unique: true
  end
end
