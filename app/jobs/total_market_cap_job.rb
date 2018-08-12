class TotalMarketCapJob < ApplicationJob
  queue_as :default

  def perform
    market = Market.all.first
    response = HTTParty.get('https://coinlib.io/api/v1/global?key=0eff52f9a4de050d')
    response = JSON.parse(response.to_s)
    market.cap = response['total_market_cap'].to_f.round 2
    market.save
  end
end
