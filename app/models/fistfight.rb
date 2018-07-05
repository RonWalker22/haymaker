class Fistfight < ApplicationRecord
  belongs_to :league
  belongs_to :attacker,    class_name: "LeagueUser", foreign_key: "attacker_id"
  belongs_to :defender,    class_name: "LeagueUser", foreign_key: "defender_id"
end
