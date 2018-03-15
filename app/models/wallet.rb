class Wallet < ApplicationRecord
  belongs_to :exchange
  belongs_to :player
  belongs_to :league
end
