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

    sell_stop_limit = "kind = 'stop' AND
                  product = '#{product}' AND
                  trigger >= #{new_price} AND
                  side = 'sell' AND
                  open = true"
    buy_stop_limit = "kind = 'stop' AND
                  product = '#{product}' AND
                  trigger <= #{new_price} AND
                  side = 'buy' AND
                  open = true"

    @orders = Order.where(sell_limit).or Order.where(buy_limit).or
                Order.where(sell_stop_limit).or Order.where(buy_stop_limit)

    if @orders
      @limit_orders       = @orders.where kind: 'limit'
      @stop_limit_orders  = @orders.where kind: 'stop'

      seperate_orders
      execute_orders(@limit_orders) unless @limit_orders.empty?
      execute_orders(@orders_ready) unless @orders_ready.empty?
      convert_orders                unless @orders_unready.empty?
    end
  end

  private
    def execute_orders orders
      orders.each do |limit_order|
        base_coin = Wallet.find limit_order.base_currency_id
        quote_coin = Wallet.find limit_order.quote_currency_id
        if limit_order.side == 'buy'
          base_coin.increment! 'total_quantity', limit_order.size
          quote_coin.decrement! 'total_quantity',
                                  (limit_order.size * new_price).round(8)

          reserve_coin = quote_coin
        else
          base_coin.decrement! 'total_quantity', limit_order.size
          quote_coin.increment! 'total_quantity',
                                  (limit_order.size * new_price).round(8)

          reserve_coin = base_coin
        end
        reserve_coin.decrement! 'reserve_quantity', limit_order.reserve_size

        limit_order.open = false
        limit_order.save
      end
    end

    def convert_orders
      @orders_unready.each do |order|
        order.update_attributes kind: 'limit'
      end
    end

    def seperate_orders

      @orders_ready   = []
      @orders_unready = []

      @stop_limit_orders.each do |order|
        if order.side == 'buy' && order.price <= new_price
          @orders_ready << order
        elsif order.side == 'sell' && order.price >= new_price
          @orders_ready << order
        else
          @orders_unready << order
        end
      end
    end
end
