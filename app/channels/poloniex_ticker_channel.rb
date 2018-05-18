class PoloniexTickerChannel < ApplicationCable::Channel
  def subscribed
    # stop_all_streams
    stream_from 'poloniex_ticker_channel'
  end

  def unsubscribed
    stop_all_streams
  end
end
