class Wallet < ApplicationRecord
  belongs_to :exchange
  belongs_to :player
end
