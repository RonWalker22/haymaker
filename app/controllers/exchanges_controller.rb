class ExchangesController < ApplicationController
  before_action :set_exchange, except: [:create, :index, :new]
  before_action :user_signed_in?, only: [:show, :edit, :update, :destroy,
                                          :order]

  def order
    @pair = params[:pair]
    @league_id = params[:id]
    @coin_1_ticker = params[:coin_1_ticker]
    @coin_2_ticker = params[:coin_2_ticker]
    @order_type = params[:commit] == "Place Buy Order" ? 'Buy' : 'Sell'
    @order_quantity = params[:order_quantity].to_f
    @wallets = current_user.wallets.where(exchange_id: @exchange.id)
    @price = @exchange.tickers.find_by(exchange_id: @exchange.id, pair: @pair).price
    set_coin_tickers
    find_and_set_coins
    create_wallet_if_missing
    execute_order if sufficient_trade_funds?

    redirect_to "/leagues/#{@league_id}/exchanges/#{@exchange.id}?p=#{@pair}"
  end

  def process_withdrawal
    if qualifying_transaction?
      transfer_funds
      flash[:notice] = 'Your transaction was successfully processed.'
    else
      flash[:alert] = 'Your transaction was unsuccessful.'
    end
    redirect_to request.original_fullpath
  end


  def index
    @exchanges = Exchange.all
  end


  def show
    @pair = params[:p]
    set_coin_tickers
    @wallets = current_user.wallets.where(exchange_id:@exchange.id)
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def exchange_params
      params.fetch(:exchange, {})
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
      unless !@wallets
        @coin_1 = @wallets.find_by({coin_type:@coin_1_ticker})
        @coin_2 = @wallets.find_by({coin_type:@coin_2_ticker})
      end
      #
    end

    def sufficient_trade_funds?
      return false if @price <= 0.00
      n = 1
      if @order_type == "Sell"
        n = -1
      end
      @coin_1_quantity_total  = @coin_1.coin_quantity + (@order_quantity *
                                n)
      @coin_2_quantity_total = @coin_2.coin_quantity - ((@price *
                                @order_quantity) * n)

      (@coin_1_quantity_total >= 0.00) && (@coin_2_quantity_total >= 0.00)
    end

    def execute_order
      @coin_1.update_attributes!(
                                {coin_quantity: @coin_1_quantity_total.round(8)}
                                )
      @coin_2.update_attributes!(
                                {coin_quantity: @coin_2_quantity_total.round(8)}
                                )

      update_order_history
    end

    def update_order_history
      wallet = @wallets.find_by(coin_type:@coin_1_ticker)
      type = wallet.coin_type
      product = @pair
      Order.create!(wallet_id: wallet.id,
                    product: @pair,
                    size: @order_quantity,
                    price: @price,
                    buy: @order_type == 'Buy',
                    open: false)
    end

    def create_wallet_if_missing
      unless @coin_1
        Wallet.create!({coin_type:  @coin_1_ticker,
                        coin_quantity: 0,
                        exchange_id: @exchange.id,
                        user_id: current_user.id,
                        public_key: SecureRandom.hex(20),
                        league_id: 1
                      })
      end
      unless @coin_2
        Wallet.create!({coin_type:  @coin_2_ticker,
                        coin_quantity: 0,
                        exchange_id: @exchange.id,
                        user_id: current_user.id,
                        public_key: SecureRandom.hex(20),
                        league_id: 1
                      })
      end
      find_and_set_coins
    end

    def get_full_coin_list
      if params[:xid].to_i == 1
        @btc_coin_list = []
        @bch_coin_list = []
        @eth_coin_list = []
        @ltc_coin_list = []

        response = HTTParty.get('https://api.gdax.com/products')
        response = JSON.parse(response.to_s)
        response.each do |hash|
          next if hash['quote_currency'] == 'EUR' || hash['quote_currency'] == 'GBP'
          if hash['base_currency'] == 'ETH'
            @eth_coin_list << hash['id']
            @eth_coin_list.sort!
          elsif hash['base_currency'] == 'BTC'
            @btc_coin_list << hash['id']
            @btc_coin_list.sort!
          elsif hash['base_currency'] == 'BCH'
            @bch_coin_list << hash['id']
            @bch_coin_list.sort!
          elsif hash['base_currency'] == 'LTC'
            @ltc_coin_list << hash['id']
            @ltc_coin_list.sort!
          end
        end
      elsif params[:xid].to_i == 2
        @btc_coin_list = []
        @bnb_coin_list = []
        @eth_coin_list = []
        @usdt_coin_list = []

        response = HTTParty.get('https://api.binance.com/api/v1/exchangeInfo')
        response = JSON.parse(response.to_s)

        response["symbols"].each do |hash|
          if hash['quoteAsset'] == 'ETH'
            @eth_coin_list << format_pair(hash['symbol'], 'ETH')
            @eth_coin_list.sort!
          elsif hash['quoteAsset'] == 'BNB'
            @bnb_coin_list << format_pair(hash['symbol'], 'BNB')
            @bnb_coin_list.sort!
          elsif hash['quoteAsset'] == 'BTC'
            @btc_coin_list << format_pair(hash['symbol'], 'BTC')
            @btc_coin_list.sort!
          elsif hash['quoteAsset'] == 'USDT'
            @usdt_coin_list << format_pair(hash['symbol'], 'USDT')
            @usdt_coin_list.sort!
          end
        end
      elsif params[:xid].to_i == 3
        @btc_coin_list = []
        @bnb_coin_list = []
        @eth_coin_list = []
        @usdt_coin_list = []

        response = HTTParty.get('https://api.hitbtc.com/api/2/public/symbol')
        response = JSON.parse(response.to_s)

        response.each do |hash|
          if hash['quoteCurrency'] == 'ETH'
            @eth_coin_list << format_pair(hash['id'], 'ETH')
            @eth_coin_list.sort!
          elsif hash['quoteCurrency'] == 'BTC'
            @btc_coin_list << format_pair(hash['id'], 'BTC')
            @btc_coin_list.sort!
          elsif hash['quoteCurrency'] == 'USD'
            @usdt_coin_list << format_pair(hash['id'], 'USD')
            @usdt_coin_list.sort!
          end
        end
      elsif params[:xid].to_i == 4
        @btc_coin_list = []
        @bnb_coin_list = []
        @eth_coin_list = []
        @usdt_coin_list = []

        response = HTTParty.get('https://api.gemini.com/v1/symbols')
        response = JSON.parse(response.to_s)

        response.each do |pair|

          @btc_coin_list << pair
          @btc_coin_list.sort!
        end
      end
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
      @giving_coin.coin_quantity >= params[:withdrawal_quantity].to_f
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
      updated_quantity = @receiving_coin.coin_quantity  + @transfer_quanity

      @receiving_coin.coin_quantity = updated_quantity
      if @receiving_coin.save
        updated_quantity = @giving_coin.coin_quantity  - @transfer_quanity
        @giving_coin.coin_quantity = updated_quantity
        @giving_coin.save
        update_transaction_history
      end
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
end
