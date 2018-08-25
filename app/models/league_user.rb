class LeagueUser < ApplicationRecord
  belongs_to :league
  belongs_to :user
  has_many   :wallets, dependent: :delete_all
  has_many   :orders,  through: :wallets         
  has_many   :bets,    dependent: :delete_all
  has_many   :attacks,
              class_name: "Fistfight",
              foreign_key: "attacker_id"
  has_many   :defenses,
              class_name: "Fistfight",
              foreign_key: "defender_id"
  paginates_per 10
end
