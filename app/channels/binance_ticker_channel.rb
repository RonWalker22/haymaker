class BinanceTickerChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    ticker = Ticker.find_by(pair: params["room"])
    stream_for ticker
  end

  def unsubscribed
    stop_all_streams
  end
end
