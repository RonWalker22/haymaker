class Player < ApplicationRecord
  validates :password, presence: true, length: { minimum: 3 }
  validates :username, presence: true, length: { maximum: 30 }
  validates :email, presence: true, length: { maximum: 255 }
  has_secure_password
end
