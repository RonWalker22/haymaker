class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    # binance ws will disconnect after a continuous 24 hour connect.
    def websocket
      binance = Exchange.find_by(name: 'Binance')
      exchange = binance.name
      EM.run {
        pairs = []
        tickers = binance.tickers.where quote_currency: 'USDT'
        tickers.each {|t| pairs << "#{t.natural_pair.downcase}@aggTrade"}
        pairs = pairs.join("/")
        @ws =  WebSocket::EventMachine::Client.connect( uri:
                    "wss://stream.binance.com:9443/ws/#{pairs}")
        @ws.onopen do
          p [:open]
        end

        @ws.onmessage do |message, type|
          ticker_stream = JSON.parse message
          ticker = tickers.find_by natural_pair: ticker_stream["s"]
          if ticker
            price = ticker_stream["p"].to_f
            ticker.update_attributes price: price
            BinanceTickerChannel.broadcast_to ticker, {price: price}
            process_ticker(ticker.pair, price)
          end
        end

        @ws.onclose do |code, reason|
          p [:close, code, reason]
          ws = nil
          ActiveRecord::Base.connection.close
          EventMachine.stop
        end
       }
     end
    Thread.new do
      loop do
        websocket
        sleep 72000
        Sidekiq::Stats.new.reset
        @ws.close
      end
    end
  end

  private

    def process_ticker(product, price)
      sell_limit = "kind = 'limit' AND
                    product = '#{product}' AND
                    price <= #{price} AND
                    side = 'sell' AND
                    open = true AND
                    ready = false"
      buy_limit = "kind = 'limit' AND
                  product = '#{product}' AND
                  price >= #{price} AND
                  side = 'buy' AND
                  open = true AND
                  ready = false"

      limit_orders = Order.where(sell_limit).or Order.where(buy_limit)

      limit_orders.each do |limit_order|
        # trigger_price could get changed multiple times
        limit_order.update_attributes! ready: true, trigger_price: new_price
      end
    end
end
