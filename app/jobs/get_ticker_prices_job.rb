require 'sidekiq/api'

class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    # binance ws will disconnect after a continuous 24 hour connect.
    # pong responses are sent automatically by client.
    def websocket
      binance = Exchange.find_by(name: 'Binance')
      exchange = binance.name
      EM.run {
        pairs = []
        tickers = binance.tickers.where(quote_currency: 'USDT')
        tickers.each {|t| pairs << "#{t.natural_pair.downcase}@aggTrade"}
        pairs = pairs.join("/")
        @ws =  WebSocket::EventMachine::Client.connect( uri:
                  "wss://stream.binance.com:9443/ws/#{pairs}")
        @ws.onopen do
          p [:open]
        end

        @ws.onmessage do |message, type|
          message = JSON.parse message
          ticker = tickers.find_by natural_pair: message["s"]
          price = message["p"].to_f
          ProcessTickerJob.perform_later(ticker, price)
        end

        @ws.onclose do |code, reason|
          p [:close, code, reason]
        end
       }
    end

    Thread.new do
      loop do
        Thread.new do
          websocket
        end
        sleep 86_000
        @ws.close
        Sidekiq::Stats.new.reset
        sleep 1
      end
    end
  end
end
