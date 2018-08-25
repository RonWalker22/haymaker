class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :league_users,                                 dependent: :delete_all
  has_many :leagues,            through: :league_users
  has_many :received_league_invites,
            foreign_key: "receiver_id",
            class_name: "LeagueInvite"
  has_many :sent_league_invites,
            foreign_key: "sender_id",
            class_name: "LeagueInvite"

  paginates_per 25

  def self.search(search)
    where("name ILIKE ?", "%#{search}%")
  end
end
