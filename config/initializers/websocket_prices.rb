def websocket
  binance = Exchange.find_by(name: 'Binance')
  exchange = binance.name
  EM.run {
     pairs = []
     tickers = binance.tickers
     tickers.each {|t| pairs << "#{t.natural_pair.downcase}@aggTrade"}
     pairs = pairs.join("/")
     @ws =  WebSocket::EventMachine::Client.connect( uri:
                "wss://stream.binance.com:9443/ws/#{pairs}")
       @ws.onopen do
         p [:open]
       end

       @ws.onmessage do |message, type|
         message = JSON.parse message
         ticker = tickers.find_by natural_pair: message["s"]
         ticker.price = message["p"].to_f
         ticker.save
         ActionCable.server.broadcast 'binance_ticker_channel',
                                                       {price: ticker.price,
                                                         pair:  ticker.pair,
                                                         exchange: exchange}
         ready_orders(ticker.pair, ticker.price)
       end

       @ws.onclose do |cdoe, reason|
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