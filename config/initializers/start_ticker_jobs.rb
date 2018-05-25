Thread.new do
  sleep(20)
  GetTickersJob.perform_now
  GetTickerPricesJob.perform_now
end
