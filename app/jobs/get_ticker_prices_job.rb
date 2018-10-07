class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    # binance ws will disconnect after a continuous 24 hour connect.
    def websocket
      binance = Exchange.find_by(name: 'Binance')
      exchange = binance.name
      EM.run {
         pairs = []
         tickers = binance.tickers
         tickers.each {|t| pairs << "#{t.natural_pair.downcase}@aggTrade"}
         pairs = pairs.join("/")
         @ws = Faye::WebSocket::Client.new("wss://stream.binance.com:9443/ws/#{pairs}")
           @ws.on :open do |event|
             p [:open]
           end

           @ws.on :message do |event|
             message = JSON.parse event.data
             ticker = tickers.find_by natural_pair: message["s"]
             ticker.price = message["p"].to_f
             ticker.save
             ActionCable.server.broadcast 'binance_ticker_channel',
                                                           {price: ticker.price,
                                                             pair:  ticker.pair,
                                                             exchange: exchange}
             ready_orders(ticker.pair, ticker.price)
           end

           @ws.on :close do |event|
             p [:close, event.code, event.reason]
             ws = nil
             ActiveRecord::Base.connection.close
             EventMachine.stop
           end
       }
     end

    loop do
      websocket
      sleep 72000
      Sidekiq::Stats.new.reset
      @ws.close
    end
  end

  private

    def ready_orders(product, new_price)

      sell_limit = "kind = 'limit' AND
                    product = '#{product}' AND
                    price <= #{new_price} AND
                    side = 'sell' AND
                    open = true AND
                    ready = false"
      buy_limit = "kind = 'limit' AND
                    product = '#{product}' AND
                    price >= #{new_price} AND
                    side = 'buy' AND
                    open = true AND
                    ready = false"

      limit_orders = Order.where(sell_limit).or Order.where(buy_limit)

      limit_orders.each do |limit_order|
        #trigger_price could get changed multiple times
        limit_order.update_attributes! ready: true, trigger_price: new_price
      end
    end
end
