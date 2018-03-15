class Player < ApplicationRecord
  has_many :wallets
  has_many :league_players
  has_many :leagues, :through => :league_players
  attr_accessor :remember_token

  validates :password, presence: false, length: { maximum: 30}
  validates :username, presence: true, length: { maximum: 30 }
  validates :email, presence: true, length: { maximum: 255 }
  validates_uniqueness_of :username
  has_secure_password

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def remember
    self.remember_token = Player.new_token
    update_attribute(:remember_digest, Player.digest(remember_token))
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def coin_total(player, coin)
    arr = [] 
    player.wallets.where({coin_type: coin}).each do 
        |wallet| arr << wallet.coin_quantity.to_i
     end
    arr.sum
  end
end
