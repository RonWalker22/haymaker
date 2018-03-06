class ExchangesController < ApplicationController
  def gdax
    if logged_in?
      @player = current_player
    else
      redirect_to login_path
    end
  end

  def binance
    unless logged_in?
      redirect_to login_path
      #message
    end
    @player = current_player
  end
end
