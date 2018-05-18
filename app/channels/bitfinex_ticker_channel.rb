class BitfinexTickerChannel < ApplicationCable::Channel
  def subscribed
    # stop_all_streams
    stream_from 'bitfinex_ticker_channel'
  end

  def unsubscribed
    stop_all_streams
  end
end
