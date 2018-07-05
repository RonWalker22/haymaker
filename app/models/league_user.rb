class LeagueUser < ApplicationRecord
  belongs_to :league
  belongs_to :user
  has_many   :wallets, dependent: :delete_all
  has_many   :bets,    dependent: :delete_all
end
