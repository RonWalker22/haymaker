class GetTickerPricesJob < ApplicationJob
  queue_as :default

  def perform
    # binance ws will disconnect after a continuous 24 hour connect.
    Thread.new do
      def websocket
        binance = Exchange.find_by(name: 'Binance')
        exchange = binance.name
        Thread.new do
          Sidekiq::Stats.new.reset
          sleep 3000
          @ws.close
        end
        EM.run {
           pairs = []
           tickers = binance.tickers
           tickers.each {|t| pairs << "#{t.natural_pair.downcase}@aggTrade"}
           pairs = pairs.join("/")
           @ws = Faye::WebSocket::Client.new("wss://stream.binance.com:9443/ws/#{pairs}")
             @ws.on :open do |event|
               p [:open]
             end

             @ws.on :message do |event|
               message = JSON.parse event.data
               ticker = tickers.find_by natural_pair: message["s"]
               ticker.price = message["p"].to_f
               ticker.save
               ActionCable.server.broadcast 'binance_ticker_channel',
                                                             {price: ticker.price,
                                                               pair:  ticker.pair,
                                                               exchange: exchange}
               Thread.new do
                process_orders(ticker.pair, ticker.price)
              end
             end

             @ws.on :close do |event|
               p [:close, event.code, event.reason]
               ws = nil
               EventMachine.stop
               ActiveRecord::Base.connection.close
             end
         }
       end

     loop do
       websocket
     end
   end
  end

  private

  def process_orders(product, new_price)

    sell_limit = "kind = 'limit' AND
                  product = '#{product}' AND
                  price <= #{new_price} AND
                  side = 'sell' AND
                  open = true"
    buy_limit = "kind = 'limit' AND
                  product = '#{product}' AND
                  price >= #{new_price} AND
                  side = 'buy' AND
                  open = true"

    limit_orders = Order.where(sell_limit).or Order.where(buy_limit)

    limit_orders.each do |limit_order|
      limit_order.update_attributes! open: false
      base_coin  = Wallet.find limit_order.base_currency_id
      quote_coin = Wallet.find limit_order.quote_currency_id
      if limit_order.side == 'buy'
        base_coin.increment! 'total_quantity', limit_order.size
        quote_coin.decrement! 'total_quantity',
                                (limit_order.size * limit_order.price).round(8)

        reserve_coin = quote_coin
      else
        base_coin.decrement! 'total_quantity', limit_order.size
        quote_coin.increment! 'total_quantity',
                                (limit_order.size * limit_order.price).round(8)

        reserve_coin = base_coin
      end
      reserve_coin.decrement! 'reserve_quantity', limit_order.reserve_size
    end
  end
end
