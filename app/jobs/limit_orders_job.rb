class LimitOrdersJob < ApplicationJob
  queue_as :default

  def perform(product, new_price)
    @product = product
    @new_price = new_price.to_f

    sell_limit = "kind = 'limit' AND
                  product = '#{@product}' AND
                  price <= #{@new_price} AND
                  side = 'sell' AND
                  open = true"
    buy_limit = "kind = 'limit' AND
                  product = '#{@product}' AND
                  price >= #{@new_price} AND
                  side = 'buy' AND
                  open = true"
    sell_stop_limit = "kind = 'stop' AND
                  product = '#{@product}' AND
                  price >= #{@new_price} AND
                  side = 'sell' AND
                  open = true"
    buy_stop_limit = "kind = 'stop' AND
                  product = '#{@product}' AND
                  price <= #{@new_price} AND
                  side = 'buy' AND
                  open = true"
    limit_orders = Order.where(sell_limit).or Order.where(buy_limit)
    @stop_limit_orders = Order.where(sell_stop_limit).or Order.where(buy_stop_limit)
    unless limit_orders.empty?
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
    unless @stop_limit_orders.empty?
      seperate_stop_orders
      execute_stop_orders(@orders_ready) unless @orders_ready.empty?
      convert_stop_orders                unless @orders_unready.empty?
    end
  end

  private

  def execute_stop_orders orders
    orders.each do |order|
      base_coin = Wallet.find order.base_currency_id
      quote_coin = Wallet.find order.quote_currency_id
      if order.side == 'buy'
        base_coin.increment! 'total_quantity', order.size
        quote_coin.decrement! 'total_quantity',
                                (order.size * @new_price).round(8)

        reserve_coin = quote_coin
      else
        base_coin.decrement! 'total_quantity', order.size
        quote_coin.increment! 'total_quantity',
                                (order.size * @new_price).round(8)

        reserve_coin = base_coin
      end
      reserve_coin.decrement! 'reserve_quantity', order.reserve_size

      order.open = false
      order.price = order.size * @new_price
      order.save
    end
  end

  def convert_stop_orders
    @orders_unready.each do |order|
      order.update_attributes kind: 'limit'
    end
  end

  def seperate_stop_orders

    @orders_ready   = []
    @orders_unready = []

    @stop_limit_orders.each do |order|
      if order.side == 'buy' && order.cap <= @new_price
        @orders_ready << order
      elsif order.side == 'sell' && order.cap >= @new_price
        @orders_ready << order
      else
        @orders_unready << order
      end
    end
  end
end
