class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    # binance ws will disconnect after a continuous 24 hour connect.
    def websocket
      binance = Exchange.find_by(name: 'Binance')
      exchange = binance.name
      Thread.new do
        sleep 80000
        @ws.close
      end
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
             LimitOrdersJob.perform_later(ticker.pair, ticker.price)
           end

           @ws.on :close do |event|
             p [:close, event.code, event.reason]
             ws = nil
             EventMachine.stop
             ActiveRecord::Base.connection.close
           end
       }
     end

   loop do
     websocket
   end

  end
end
