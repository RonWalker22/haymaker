module SessionsHelper

  def log_in(player)
    session[:player_id] = player.id
  end

  def current_player
    if (player_id = session[:player_id])
      @current_player ||= Player.find_by(id: player_id)
    elsif (player_id = cookies.signed[:player_id])
      player = Player.find_by(id: player_id)
      if player && player.authenticated?(cookies[:remember_token])
        log_in player
        @current_player = player
      end
    end
  end

  def logged_in?
    !current_player.nil?
  end

  def current_player?(player)
    player == current_player
  end

  def remember(player)
    player.remember
    cookies.permanent.signed[:player_id] = player.id
    cookies.permanent[:remember_token] = player.remember_token
  end

  def forget(player)
    player.forget
    cookies.delete(:player_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_player)
    session.delete(:player_id)
    @current_player = nil
  end
end
