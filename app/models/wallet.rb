class Wallet < ApplicationRecord
  has_many :orders,
            foreign_key: "base_currency_id",
            class_name: "Order",
            dependent: :delete_all
  has_many   :transaction_histories, dependent: :delete_all
  belongs_to :exchange
  belongs_to :league_user

  def available_quantity
    self.total_quantity - self.reserve_quantity
  end
end
