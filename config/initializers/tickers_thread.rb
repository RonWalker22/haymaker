Thread.new do
  def format_pair(pair, match)
    mid_point = pair =~ /#{match}/
    coin_1_ticker = []
    coin_2_ticker = []
    pair.size.times do |n|
      coin_1_ticker << pair[n] if n < mid_point
      coin_2_ticker << pair[n] if n >= mid_point
    end
    "#{coin_1_ticker.join}-#{coin_2_ticker.join}"
  end

  response = HTTParty.get('https://api.binance.com/api/v1/exchangeInfo')
  response = JSON.parse(response.to_s)
  pairs = []
  binance = Exchange.find_by name:'Binance'
  binance.tickers.each do |ticker|
   pairs << ticker.natural_pair
  end
  response["symbols"].each do |hash|
   next if pairs.any? {|pair| pair == hash['symbol']}

   new_ticker = Ticker.new({pair: format_pair(hash['symbol'], hash['quoteAsset']),
                           natural_pair: hash['symbol'],
                           base_currency: hash['baseAsset'],
                           quote_currency: hash['quoteAsset'], price: 0.0,
                           exchange_id: binance.id
                           })
   new_ticker.save
  end
end

@binance_threads = []
binance = Exchange.find_by name:'Binance'
Thread.new do
  @binance_threads.each {|t| t.kill} if @binance_threads
  @binance_threads << Thread.current
  sleep(20)
  loop do
    response = HTTParty.get('https://api.binance.com/api/v3/ticker/price')
    puts "start"
    response = JSON.parse(response.to_s)

    response.each do |hash|
      ticker = binance.tickers.find_by natural_pair: hash["symbol"]
      ticker.price = hash["price"].to_f if ticker
      ticker.save
      ActionCable.server.broadcast 'binance_ticker_channel',
                                                    {price: ticker.price,
                                                      pair:  ticker.pair,
                                                      exchange: 'Binance'}
    end
    sleep(1)
  end
  ActiveRecord::Base.connection.close
end
