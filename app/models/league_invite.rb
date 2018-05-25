class LeagueInvite < ApplicationRecord
  default_scope { order(created_at: :desc) }
  
  belongs_to :league
  belongs_to :sender,    class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver,  class_name: "User", foreign_key: "receiver_id"
end
