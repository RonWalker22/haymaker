Thread.new do
  sleep(10)
  GetTickersJob.perform_later
  sleep(15)
  GetTickerPricesJob.perform_now
end
