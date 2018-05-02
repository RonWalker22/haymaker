class Wallet < ApplicationRecord
  has_many   :orders
  has_many   :transaction_histories
  belongs_to :exchange
  belongs_to :user
  belongs_to :league
end
