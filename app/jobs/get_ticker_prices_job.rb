class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    # binance ws will disconnect after a continuous 24 hour connect.
    def websocket
      binance = Exchange.find_by(name: 'Binance')
      exchange = binance.name
      EM.run {
        pairs = []
        tickers = binance.tickers.where quote_currency: "USDT"
        tickers.each {|t| pairs << "#{t.natural_pair.downcase}@ticker"}
        pairs = pairs.join("/")
        @ws =  WebSocket::EventMachine::Client.connect( uri:
                    "wss://stream.binance.com:9443/ws/#{pairs}")
        @ws.onopen do
          p [:open]
        end

        @ws.onmessage do |message, type|
          ticker_stream = JSON.parse message
          ticker = tickers.find_by natural_pair: ticker_stream["s"]
          if ticker
            price = ticker_stream["c"].to_f
            ProcessTickerJob.perform_later(ticker, price)
          end
        end

        @ws.onclose do |code, reason|
          p [:close, code, reason]
          ws = nil
          ActiveRecord::Base.connection.close
          EventMachine.stop
        end
       }
     end
    Thread.new do
      loop do
        websocket
        sleep 72000
        Sidekiq::Stats.new.reset
        @ws.close
      end
    end
  end
end
