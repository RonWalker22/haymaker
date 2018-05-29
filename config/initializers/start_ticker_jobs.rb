Thread.new do
  sleep(30)
  # GetTickersJob.perform_now
  # GetTickerPricesJob.set(wait: 30.seconds).perform_later
  # GetTickerPricesJob.perform_now
  # SimpleJob.perform_later
  # GetTickersJob.perform_now
  GetTickerPricesJob.perform_later
end
