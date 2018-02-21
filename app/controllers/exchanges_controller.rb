class ExchangesController < ApplicationController
  def gdax
    @player = current_player
  end

  def binance
    @player = current_player
  end
end
