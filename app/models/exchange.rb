class Exchange < ApplicationRecord
  has_many :wallets
  has_many :exchange_leagues 
  has_many :leagues, :through => :exchange_leagues 
end
