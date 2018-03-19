class Wallet < ApplicationRecord
  has_many   :orders
  belongs_to :exchange
  belongs_to :player
  belongs_to :league
end
