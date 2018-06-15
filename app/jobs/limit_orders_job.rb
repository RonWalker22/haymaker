class LimitOrdersJob < ApplicationJob
  queue_as :default

  def perform(product, new_price)

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
    if limit_orders
      limit_orders.each do |limit_order|
        base_coin = Wallet.find limit_order.base_currency_id
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

        limit_order.open = false
        limit_order.save
      end
    end
  end
end
