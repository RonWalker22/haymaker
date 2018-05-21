class CreateLeagueUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :league_users do |t|
      t.references :league
      t.references :user
      t.boolean :ready,  default: false, null: false
      t.boolean :set_up, default: false, null: false
      t.string :status,  default: "alive", null: false

      t.timestamps
    end
    add_index :league_users,
              [:league_id, :user_id],
              unique: true
  end
end
