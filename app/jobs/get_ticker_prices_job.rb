class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    tickers = Ticker.all
    response = HTTParty.get('https://api.binance.com/api/v1/ticker/price')
    response = JSON.parse(response.to_s)
    response.each do |ticker|
      symbol = ticker["symbol"]
      new_price = ticker["price"].to_f
      ticker = tickers.find_by(natural_pair: symbol)
      if ticker && ticker.price != new_price
        ticker.price = new_price
        ticker.save
        BinanceTickerChannel.broadcast_to ticker, price: new_price
        ProcessTickerJob.perform_later(ticker.pair, new_price)
      end
    end
  end
end
