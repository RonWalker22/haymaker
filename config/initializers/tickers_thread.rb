gdax = Exchange.find_by name:'GDAX'
gemini = Exchange.find_by name:'Gemini'
binance = Exchange.find_by name:'Binance'
@ticker_threads ||= []
Thread.new do
  sleep(3)
  @ticker_threads.each {|t| t.kill}
  @ticker_threads = [Thread.current]
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

  #GDAX pairs
  response = HTTParty.get('https://api.gdax.com/products')
  response = JSON.parse(response.to_s)
  pairs = []
  gdax_id = gdax.id
  gdax.tickers.each do |ticker|
    pairs << ticker.natural_pair
  end
  response.each do |hash|
    gdax_tickers = gdax.tickers
    next if pairs.any? {|pair| pair == hash['id']}

    new_ticker = Ticker.new({pair: hash['id'], natural_pair: hash['id'],
                            base_currency: hash['base_currency'],
                            quote_currency: hash['quote_currency'], price: 0.0,
                            exchange_id: gdax_id
                            })
    new_ticker.save
  end

  #BINANCE pairs
  response = HTTParty.get('https://api.binance.com/api/v1/exchangeInfo')
  response = JSON.parse(response.to_s)
  pairs = []
  binance_id = binance.id
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

  # GEMINI pairs // API doesn't give enough info.
  # response = HTTParty.get('https://api.gemini.com/v1/symbols')
  # response = JSON.parse(response.to_s)
  #
  # response.each do |pair|
  #   @gemini = Exchange.find_by name:'GDAX'
  #   next if @gemini.tickers.any? {|ticker| ticker.pair == pair}
  #
  #   new_ticker = Ticker.new({pair: pair, price: 0.0,
  #                           exchange_id: @gemini.id
  #                           })
  #   new_ticker.save
  # end
  gemini_pairs = []
  gemini_id = gemini.id
  gemini.tickers.each do |ticker|
    gemini_pairs << ticker.natural_pair
  end
  3.times do |i|
    case i
    when 0
      pair           = 'BTC-USD'
      natural_pair   = 'btcusd'
      base_currency  = 'BTC'
      quote_currency = 'USD'
    when 1
      pair           = 'ETH-BTC'
      natural_pair   = 'ethbtc'
      base_currency  = 'ETH'
      quote_currency = 'BTC'
    when 2
      pair           = 'ETH-USD'
      natural_pair   = 'ethusd'
      base_currency  = 'ETH'
      quote_currency = 'USD'
    end
    next if gemini_pairs.any? {|gemini_pair| gemini_pair == natural_pair}
    new_ticker = Ticker.new({pair: pair, natural_pair: natural_pair,
                            base_currency: base_currency,
                            quote_currency: quote_currency,
                            price: 0.0,
                            exchange_id: gemini_id
                            })

    new_ticker.save
  end
end
