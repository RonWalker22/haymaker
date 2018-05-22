class Wallet < ApplicationRecord
  has_many   :orders, dependent: :delete_all
  has_many   :transaction_histories, dependent: :delete_all
  belongs_to :exchange
  belongs_to :league_user
end
