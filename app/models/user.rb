class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :wallets, dependent: :delete_all
  has_many :league_users, dependent: :delete_all
  has_many :leagues, :through => :league_users

  def coin_total(coin)
    arr = []
    self.wallets.where({coin_type: coin}).each do
        |wallet| arr << wallet.coin_quantity.to_i
     end
    arr.sum
  end
end
