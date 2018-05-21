class Exchange < ApplicationRecord
  has_many :wallets, dependent: :delete_all
  has_many :exchange_leagues, dependent: :delete_all
  has_many :leagues, :through => :exchange_leagues, dependent: :delete_all
  has_many :tickers, dependent: :delete_all
end
