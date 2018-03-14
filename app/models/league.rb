class League < ApplicationRecord
  has_many :league_players
  has_many :players, :through => :league_players
  has_many :exchange_leagues 
  has_many :exchanges, :through => :exchange_leagues 
end
