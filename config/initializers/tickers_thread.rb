@gdax     = Exchange.find_by name:'GDAX'
@poloniex = Exchange.find_by name:'Poloniex'
@bitfinex = Exchange.find_by name:'Bitfinex'
@binance  = Exchange.find_by name:'Binance'


Thread.new do
  sleep(5)
  def get_binance_tickers
    response = HTTParty.get('https://api.binance.com/api/v1/exchangeInfo')
    response = JSON.parse(response.to_s)
    pairs = []
    @binance.tickers.each do |ticker|
     pairs << ticker.natural_pair
    end
    response["symbols"].each do |hash|
     next if pairs.any? {|pair| pair == hash['symbol']}

     new_ticker = Ticker.new(
                            {pair: "#{hash['baseAsset']}-#{hash['quoteAsset']}",
                             natural_pair:   hash['symbol'],
                             base_currency:  hash['baseAsset'],
                             quote_currency: hash['quoteAsset'],
                             price:          0.0,
                             exchange_id:    @binance.id
                             })
     new_ticker.save
    end
  end

  def get_gdax_tickers
    response = HTTParty.get('https://api.gdax.com/products')
    response = JSON.parse(response.to_s)
    pairs = []
    @gdax.tickers.each do |ticker|
      pairs << ticker.natural_pair
    end
    response.each do |hash|
      next if pairs.any? {|pair| pair == hash['id']}

      new_ticker = Ticker.new({pair:          hash['id'],
                              natural_pair:   hash['id'],
                              base_currency:  hash['base_currency'],
                              quote_currency: hash['quote_currency'],
                              price:          0.0,
                              exchange_id:    @gdax.id
                              })
      new_ticker.save
    end
  end

  def get_bitfinex_tickers
    response = HTTParty.get("https://api.bitfinex.com/v1/symbols")
    response = JSON.parse(response.to_s)

    outer_pairs = []
    @bitfinex.tickers.each do |ticker|
     outer_pairs << ticker.natural_pair
    end

    response.each do |pair|
      quote_currency = pair.slice!(-3, 3)
      base_currency = pair
      next if outer_pairs.any? {|x| x == "#{base_currency}#{quote_currency}"}
      pair           = "#{base_currency}-#{quote_currency}"
      natural_pair   = "#{base_currency}#{quote_currency}"

      new_ticker = Ticker.new({ pair:           pair.upcase,
                                natural_pair:   natural_pair,
                                base_currency:  base_currency.upcase,
                                quote_currency: quote_currency.upcase,
                                price:          0.0,
                                exchange_id:    @bitfinex.id
                              })
      new_ticker.save
    end
  end

  def get_poloniex_tickers
    response = HTTParty.get("https://poloniex.com/public?command=returnTicker")
    response = JSON.parse(response.to_s)

    pairs = []
    @poloniex.tickers.each do |ticker|
     pairs << ticker.natural_pair
    end

    pairs_arr = response.to_a
    pairs_arr.each do |pair|
      next if pairs.any? {|x| x == pair[0]}
      natural_pair   = pair[0]
      base_currency  = pair[0].split('_')[1]
      quote_currency = pair[0].split('_')[0]
      price          = pair[1]["last"].to_f.round(8)
      pair           = "#{base_currency}-#{quote_currency}"
      new_ticker = Ticker.new({ pair: pair,
                                natural_pair:   natural_pair,
                                base_currency:  base_currency,
                                quote_currency: quote_currency,
                                price:          price,
                                exchange_id:    @poloniex.id
                              })
      new_ticker.save
    end
  end

  get_binance_tickers
  get_gdax_tickers
  get_poloniex_tickers
  get_bitfinex_tickers

  ActiveRecord::Base.connection.close
end



# About delay about 2 seconds
@binance_threads = []
Thread.new do
  @binance_threads.each {|t| t.kill} if @binance_threads
  @binance_threads << Thread.current
  sleep(10)
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


# Delay abount 1 second
@poloniex_threads = []
Thread.new do
  @poloniex_threads.each {|t| t.kill} if @poloniex_threads
  @poloniex_threads << Thread.current
  sleep(10)
  loop do
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


# About 2 seconds delay
@bitfinex_threads = []
Thread.new do
  @bitfinex_threads.each {|t| t.kill} if @bitfinex_threads
  @bitfinex_threads << Thread.current
  sleep(10)
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
    sleep(1)
  end
  ActiveRecord::Base.connection.close
end
