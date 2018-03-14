class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  
  def check_logged_in_and_premissions
    
  end



  def check_permissions
    if check_logged_in
      return 
    elsif current_player.admin?
      return
    elsif !current_player?(@player)
      flash[:notice] = "You have not been granted access to that section."
      redirect_to leaderboards_path
    end
  end

  def check_logged_in
    if !logged_in?
      store_location
      flash[:notice] = 'Please log in.'
      redirect_to login_path
    end
  end
end
