class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    @gdax     = Exchange.find_by name:'GDAX'
    @poloniex = Exchange.find_by name:'Poloniex'
    @bitfinex = Exchange.find_by name:'Bitfinex'
    @binance  = Exchange.find_by name:'Binance'

    # Up to 2 seconds delay
    @binance_threads = []
    Thread.new do
      @binance_threads.each {|t| t.kill} if @binance_threads
      @binance_threads << Thread.current
      binance = Exchange.find_by name:'Binance'
      loop do
        response = HTTParty.get('https://api.binance.com/api/v3/ticker/price')
        response = JSON.parse(response.to_s)

        response.each do |hash|
          ticker = @binance.tickers.find_by natural_pair: hash["symbol"]
          if ticker
            ticker.price = hash["price"].to_f
            ticker.save
            ActionCable.server.broadcast 'binance_ticker_channel',
                                                          {price: ticker.price,
                                                            pair:  ticker.pair,
                                                            exchange: @binance.name}
          end
        end
      end
      ActiveRecord::Base.connection.close
    end

    #Up to 3 seconds delay
    @bitfinex_threads = []
    Thread.new do
      @bitfinex_threads.each {|t| t.kill} if @bitfinex_threads
      @bitfinex_threads << Thread.current
      base = "https://api.bitfinex.com/v2/tickers?symbols="
      pairs = []
      @bitfinex.tickers.each {|t| pairs << "t#{t.natural_pair.upcase}"}
      pairs = pairs.join(",")
      loop do
        response = HTTParty.get("#{base}#{pairs}")
        response = JSON.parse(response.to_s)
        response.each do |pair|
          pair_target = pair[0].delete('t').downcase
          ticker = @bitfinex.tickers.find_by natural_pair: pair_target
          if ticker
            ticker.price = pair[-4].to_f.round(8)
            ticker.save
            ActionCable.server.broadcast 'bitfinex_ticker_channel',
                                                        {price:     ticker.price,
                                                          pair:     ticker.pair,
                                                          exchange: @bitfinex.name}
          end
        end

        response = HTTParty.get('https://poloniex.com/public?command=returnTicker')
        response = JSON.parse(response.to_s)

        response.to_a.each do |arr|
          ticker = @poloniex.tickers.find_by natural_pair: arr[0]
          if ticker
            ticker.price = arr[1]["last"].to_f.round(8)
            ticker.save
            ActionCable.server.broadcast 'poloniex_ticker_channel',
                                                          {price: ticker.price,
                                                          pair:  ticker.pair,
                                                          exchange: @poloniex.name}
         end
       end
      end
      ActiveRecord::Base.connection.close
    end
  end
end
