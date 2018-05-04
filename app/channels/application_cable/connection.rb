module ApplicationCable
  class Connection < ActionCable::Connection::Base
  include Devise::Controllers::Helpers
  
  identified_by :ticker_user

  def connect
    self.ticker_user = find_verified_user
  end

  private

    def find_verified_user
      if user_signed_in?
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
