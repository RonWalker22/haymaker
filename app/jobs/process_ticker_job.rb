class ProcessTickerJob < ApplicationJob
  queue_as :default

  def perform(ticker, price)
    ActiveRecord::Base.connection_pool.with_connection do
      ticker.price = price
      if ticker.save
        BinanceTickerChannel.broadcast_to ticker, {price: price}
        ready_orders(ticker.pair, price)
      end
    end
  end

  private 
    def ready_orders(product, new_price)

      sell_limit = "kind = 'limit' AND
                    product = '#{product}' AND
                    price <= #{new_price} AND
                    side = 'sell' AND
                    open = true AND
                    ready = false"
      buy_limit = "kind = 'limit' AND
                    product = '#{product}' AND
                    price >= #{new_price} AND
                    side = 'buy' AND
                    open = true AND
                    ready = false"

      limit_orders = Order.where(sell_limit).or Order.where(buy_limit)

      limit_orders.each do |limit_order|
        #trigger_price could get changed multiple times
        limit_order.update_attributes! ready: true, trigger_price: new_price
      end
    end
end
