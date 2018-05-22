class LeagueUser < ApplicationRecord
  has_many   :wallets, dependent: :delete_all
  
  belongs_to :league
  belongs_to :user
end
