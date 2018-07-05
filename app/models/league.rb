class League < ApplicationRecord
  has_many :league_users,                                 dependent: :delete_all
  has_many :wallets,         :through => :league_users
  has_many :users,           :through => :league_users
  has_many :exchange_leagues,                             dependent: :delete_all
  has_many :exchanges,       :through => :exchange_leagues
  has_many :league_invites,                               dependent: :delete_all
  has_many :bets,            :through => :league_users
  has_many :fistfights
end
