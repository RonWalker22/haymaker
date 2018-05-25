class CreateLeagueInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :league_invites do |t|
      t.references :league, null: false
      t.references :receiver,
                    index: true,
                    foreign_key: {to_table: :users},
                   null: false
      t.references :sender,
                    index: true,
                    foreign_key: {to_table: :users},
                    null: false
      t.string :status,  default: "pending", null: false

      t.timestamps
    end
    add_index :league_invites,
              [:league_id, :receiver_id],
              unique: true
  end
end
