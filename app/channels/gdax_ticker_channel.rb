class GdaxTickerChannel < ApplicationCable::Channel
  def subscribed
    # stop_all_streams
    stream_from 'gdax_ticker_channel'
  end

  def unsubscribed
    stop_all_streams
  end
end
