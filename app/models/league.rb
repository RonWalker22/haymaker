class League < ApplicationRecord
  has_many :wallets
  has_many :league_players, dependent: :delete_all
  has_many :players, :through => :league_players
  has_many :exchange_leagues 
  has_many :exchanges, :through => :exchange_leagues
end
