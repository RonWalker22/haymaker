class GetTickersJob < ApplicationJob
  queue_as :default

  def perform
    @binance  = Exchange.find_by name:'Binance'
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
end
