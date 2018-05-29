class GetTickersJob < ApplicationJob
  queue_as :default

  def perform
    @gdax     = Exchange.find_by name:'GDAX'
    @poloniex = Exchange.find_by name:'Poloniex'
    @bitfinex = Exchange.find_by name:'Bitfinex'
    @binance  = Exchange.find_by name:'Binance'

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
  end
end
