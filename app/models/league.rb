class League < ApplicationRecord
  has_many :wallets
  has_many :league_users, dependent: :delete_all
  has_many :users, :through => :league_users
  has_many :exchange_leagues
  has_many :exchanges, :through => :exchange_leagues
end
