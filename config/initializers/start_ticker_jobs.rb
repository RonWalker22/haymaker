Thread.new do
  sleep(20)
  GetTickersJob.perform_now
  sleep(10)
  GetTickerPricesJob.perform_now
end
