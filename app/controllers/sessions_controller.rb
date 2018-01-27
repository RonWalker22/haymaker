class SessionsController < ApplicationController
  def new
  end

  def create
    player = Player.find_by(email: params[:session][:email])
    if player && player.authenticate(params[:session][:password])
      log_in(player)
      redirect_to leaderboards_path
    else
      flash.now[:notice] = "That email and or password is invaild."
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to leaderboards_path
  end
end
