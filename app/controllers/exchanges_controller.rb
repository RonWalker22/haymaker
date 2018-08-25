class ExchangesController < ApplicationController
  before_action :check_signed_in
  before_action :set_exchange, except: [:create, :index, :new]
  before_action :set_league_user, except: [:create, :index, :new, :update,
                                          :destroy]
  before_action :check_trading_window, only: [:order]
  before_action :order_params, only: [:order]
  before_action :user_signed_in?, only: [:show, :edit, :update, :destroy,
                                        :order]

  def order
    @pair = params[:pair]
    @league_id = params[:id]
    @coin_1_ticker = params[:coin_1_ticker]
    @coin_2_ticker = params[:coin_2_ticker]
    @order_type = params[:commit] == "Place Buy Order" ? 'buy' : 'sell'
    @order_quantity = params[:order_quantity].to_f

    @wallets = @league_user.wallets.where(exchange_id: @exchange.id,
                                          league_user_id: @league_user.id )
    establish_price
    set_coin_tickers
    find_and_set_coins
    create_wallet_if_missing
    if sufficient_trade_funds?
      if custom_order?
        update_reserves
      else
        execute_order
      end
      update_order_history
    else
      flash[:alert] = 'Your account does not have sufficient funds to cover your order.'
    end
    redirect_to trade_path(@league_id, @exchange.id, p:@pair)
  end

  def delete_custom_order
    @order = @league_user.orders.find order_params[:oid]
    if @order
      remove_reserve
      @order.destroy
    else
      flash[:alert] = "You can only cancel orders which belong to you."
    end
    redirect_back(fallback_location: root_path)
  end

  def index
    @exchanges = Exchange.all
  end


  def show
    @pair = params[:p]
    set_coin_tickers
    if !@league_user.alive?
      flash[:notice] = "You have been knocked out of this league and are no
                                longer able to access any league featues."
      return redirect_back(fallback_location: root_path)
    end
    @wallets = @league_user.wallets.where(exchange_id: @exchange.id)

    @wallet = @wallets.find_by(coin_type:@coin_1_ticker)
    find_and_set_coins
    get_full_coin_list

    ticker = Ticker.first
  end

  def new
    @exchange = Exchange.new
  end

  def create
    @exchange = Exchange.new(exchange_params)

    respond_to do |format|
      if @exchange.save
        format.html { redirect_to @exchange, flash[:notice] = 'Exchange was successfully created.' }
        format.json { render :show, status: :created, location: @exchange }
      else
        format.html { render :new }
        format.json { render json: @exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @exchange.update(exchange_params)
        format.html { redirect_to @exchange, flash[:notice] = 'Exchange was successfully updated.' }
        format.json { render :show, status: :ok, location: @exchange }
      else
        format.html { render :edit }
        format.json { render json: @exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @exchange.destroy
    respond_to do |format|
      format.html { redirect_to exchanges_url, notice: 'Exchange was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exchange
      @exchange = Exchange.find(params[:xid])
    end

    def set_league_user
      @league_user = LeagueUser.find_by(user_id: current_user.id,
                                        league_id: params[:id].to_i)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exchange_params
      params.fetch(:exchange, {})
    end

    def order_params
      params.permit(:price_target, :direction, :price_cap, :oid)
    end

    def remove_reserve

    end

    def set_coin_tickers
      mid_point = @pair =~ /-/
      @coin_1_ticker = []
      @coin_2_ticker = []
      @pair.size.times do |n|
        @coin_1_ticker << @pair[n] if n < mid_point
        @coin_2_ticker << @pair[n] if n > mid_point
      end
      @coin_1_ticker = @coin_1_ticker.join
      @coin_2_ticker = @coin_2_ticker.join
    end

    def find_and_set_coins
      if @wallets
        @coin_1 = @wallets.find_by({coin_type:@coin_1_ticker})
        @coin_2 = @wallets.find_by({coin_type:@coin_2_ticker})
      end
    end

    def sufficient_trade_funds?
      return false if @price <= 0.00

      n = (@order_type == "buy" ? 1 : -1)

      @coin_1_increment = @order_quantity * n
      @coin_2_decrement = ((@price * @order_quantity).round(8) * n)

      coin_1_quantity_total  = @coin_1.total_quantity + @coin_1_increment
      coin_2_quantity_total = @coin_2.total_quantity - @coin_2_decrement

      (coin_1_quantity_total >= 0.00) && (coin_2_quantity_total >= 0.00)
    end

    def execute_order
      @coin_1.increment! 'total_quantity', @coin_1_increment
      @coin_2.decrement! 'total_quantity', @coin_2_decrement
    end

    def update_order_history
      establish_reserve_size
      wallet       = @wallets.find_by(coin_type:@coin_1_ticker)
      type         = wallet.coin_type
      product      = @pair
      kind         = (custom_order? ? 'limit' : 'market' )
      order_open   = (custom_order? ? true : false )
      Order.create!(product: @pair,
                    size: @order_quantity,
                    price: @price,
                    side: @order_type,
                    open: order_open,
                    kind: kind,
                    reserve_size: @reserve_size,
                    base_currency_id: @coin_1.id,
                    quote_currency_id: @coin_2.id )
    end

    def establish_reserve_size
      return @reserve_size = 0 unless custom_order?

      if @order_type == 'buy'
        @reserve_size = @coin_2_decrement.abs
      else
        @reserve_size = @order_quantity
      end
    end

    def create_wallet_if_missing
      unless @coin_1
        Wallet.create!({coin_type:  @coin_1_ticker,
                        total_quantity: 0,
                        exchange_id: @exchange.id,
                        league_user_id: @league_user.id,
                        public_key: SecureRandom.hex(20)
                      })
      end
      unless @coin_2
        Wallet.create!({coin_type:  @coin_2_ticker,
                        total_quantity: 0,
                        exchange_id: @exchange.id,
                        league_user_id: @league_user.id,
                        public_key: SecureRandom.hex(20)
                      })
      end
      find_and_set_coins
    end

    def get_full_coin_list
      @ticker_list = {}

      Ticker.all.order(:pair).each do |ticker|
        if @ticker_list[ticker["quote_currency"]]
          @ticker_list[ticker["quote_currency"]] << ticker
        else
          @ticker_list[ticker["quote_currency"]] = [ticker]
        end
      end

      @ticker_list = @ticker_list.values
    end

    def format_pair(pair, match)
      mid_point = pair =~ /#{match}/
      coin_1_ticker = []
      coin_2_ticker = []
      pair.size.times do |n|
        coin_1_ticker << pair[n] if n < mid_point
        coin_2_ticker << pair[n] if n >= mid_point
      end
      "#{coin_1_ticker.join}-#{coin_2_ticker.join}"
    end

    def sufficient_funds_to_transfer?
      @giving_coin.total_quantity >= params[:withdrawal_quantity].to_f
    end

    def equivalent_pairs?
      receiving_target = {public_key: params[:deposit_address]}
      giving_target = {exchange_id: params[:xid], league_id: params[:id],
                      coin_type: params[:cid] }
      @receiving_coin = current_user.wallets.find_by(receiving_target)
      @giving_coin = current_user.wallets.find_by(giving_target)
      return false if @receiving_coin == nil || @giving_coin == nil
      @receiving_coin.coin_type == @giving_coin.coin_type &&
        @receiving_coin.league_id == @giving_coin.league_id
    end

    def transfer_to_same_user?
      @receiving_coin.user_id == @giving_coin.user_id
    end

    def giving_coin_not_usd?
      @giving_coin.coin_type.upcase != 'USD'
    end

    def qualifying_transaction?
      equivalent_pairs? && sufficient_funds_to_transfer? &&
        giving_coin_not_usd? && transfer_to_same_user?
    end

    def transfer_funds
      @transfer_quanity = params[:withdrawal_quantity].to_f
      updated_quantity = @receiving_coin.total_quantity  + @transfer_quanity

      @receiving_coin.total_quantity = updated_quantity
      if @receiving_coin.save
        updated_quantity = @giving_coin.total_quantity  - @transfer_quanity
        @giving_coin.total_quantity = updated_quantity
        @giving_coin.save
        update_transaction_history
      end
    end

    def method_name

    end

    def update_transaction_history
      target_hash = {wallet_id: @giving_coin.id, amount:@transfer_quanity,
                      address: @giving_coin.public_key,
                      coin: @giving_coin.coin_type, deposit_type:false}
      TransactionHistory.create!(target_hash)
      target_hash = {wallet_id: @receiving_coin.id, amount:@transfer_quanity,
                      address: @receiving_coin.public_key,
                      coin: @receiving_coin.coin_type, deposit_type:true}
      TransactionHistory.create!(target_hash)
    end

    def check_trading_window
      league = League.find(params[:id])
      if league.start_date.future? || league.end_date.past?
        flash[:notice] = "You are unable to trade at this time. The trading
                          window is closed."
        return redirect_to league_path(league)
      else
        nil
      end
    end

    def limit_order
      order_params[:price_target] != "" && order_params[:price_cap] == ""
    end

    def stop_limit_order
      order_params[:price_target] !=  "" && order_params[:price_cap] != ""
    end

    def establish_price
      if limit_order
        @price = order_params[:price_target].to_f
      elsif stop_limit_order
        @price = order_params[:price_cap].to_f
      else
        @price = @exchange.tickers.find_by(exchange_id: @exchange.id,
                                           pair: @pair).price
      end
    end

    def custom_order?
      order_params[:price_target] != ""
    end

    def update_reserves
      if @order_type == 'buy'
        @coin_2.increment! 'reserve_quantity', @coin_2_decrement.abs
      else
        @coin_1.increment! 'reserve_quantity', @coin_1_increment.abs
      end
    end
end
