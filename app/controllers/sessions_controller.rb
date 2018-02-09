class SessionsController < ApplicationController
  def new
  end

  def create
    player = Player.find_by(email: params[:session][:email])
    if player && player.authenticate(params[:session][:password])
      log_in player
      params[:session][:remember_me] == '1' ? remember(player) : forget(player)
      redirect_back_or leaderboards_path
    else
      flash.now[:notice] = "That email and or password is invaild."
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to leaderboards_path
  end
end
