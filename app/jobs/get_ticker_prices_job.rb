class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    # binance ws will disconnect after 24 hours.

    binance = Exchange.find_by(name: 'Binance')
    exchange = binance.name
    EM.run {
       pairs = []
       tickers = binance.tickers
       tickers.each {|t| pairs << "#{t.natural_pair.downcase}@aggTrade"}
       pairs = pairs.join("/")
       ws = Faye::WebSocket::Client.new("wss://stream.binance.com:9443/ws/#{pairs}")
         ws.on :open do |event|
           p [:open]
         end

         ws.on :message do |event|
           message = JSON.parse event.data
           ticker = tickers.find_by natural_pair: message["s"]
           ticker.price = message["p"].to_f
           ticker.save
           ActionCable.server.broadcast 'binance_ticker_channel',
                                                         {price: ticker.price,
                                                           pair:  ticker.pair,
                                                           exchange: exchange}
           # LimitOrdersJob.perform_later(ticker.pair, ticker.price)
         end

         ws.on :close do |event|
           p [:close, event.code, event.reason]
           ws = nil
         end
     }

     # @binance  = Exchange.find_by name:'Binance'
     #
     # Up to 2 seconds delay
     # @binance_threads = []
     # Thread.new do
     #   @binance_threads.each {|t| t.kill} if @binance_threads
     #   @binance_threads << Thread.current
     #   binance = Exchange.find_by name:'Binance'
     #   loop do
     #     response = HTTParty.get('https://api.binance.com/api/v3/ticker/price')
     #     response = JSON.parse(response.to_s)
     #
     #     response.each do |hash|
     #       ticker = @binance.tickers.find_by natural_pair: hash["symbol"]
     #       if ticker
     #         ticker.price = hash["price"].to_f
     #         ticker.save
     #         ActionCable.server.broadcast 'binance_ticker_channel',
     #                                       {price: ticker.price,
     #                                         pair:  ticker.pair,
     #                                         exchange: @binance.name}
     #         LimitOrdersJob.perform_later(ticker.pair, ticker.price)
     #       end
     #     end
     #   end
     #   ActiveRecord::Base.connection.close
     # end
  end
end
