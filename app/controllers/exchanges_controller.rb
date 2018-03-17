class ExchangesController < ApplicationController
  before_action :set_exchange, only: [:show, :edit, :update, :destroy, :order]
  before_action :check_logged_in, only: [:show, :edit, :update, :destroy,
                                          :order]

  def order
    @pair = params[:pair]
    @league = params[:league]
    @coin_1_ticker = params[:coin_1_ticker]
    @coin_2_ticker = params[:coin_2_ticker]
    @order = params[:commit]
    @price = params[:order_price].to_f
    return "Invaid price" if @price < 0.0
    @order_quantity = params[:order_quantity].to_f
    
    @wallets = current_player.wallets.where(exchange_id: @exchange.id)

    set_coin_tickers

    find_and_set_coins

    create_wallet_if_missing
  

    execute_order if sufficient_funds?

    redirect_to "/exchanges/#{@exchange.id}?p=#{@pair}"
  end
  

  # GET /exchanges
  # GET /exchanges.json
  def index
    @exchanges = Exchange.all
  end

  # GET /exchanges/1
  # GET /exchanges/1.json
  
  def show
    @pair = params[:p]
    @wallets = current_player.wallets.where(exchange_id:@exchange.id)
    set_coin_tickers
    find_and_set_coins
  end

  # GET /exchanges/new
  def new
    @exchange = Exchange.new
  end

  # GET /exchanges/1/edit
  def edit
  end

  # POST /exchanges
  # POST /exchanges.json
  def create
    @exchange = Exchange.new(exchange_params)

    respond_to do |format|
      if @exchange.save
        format.html { redirect_to @exchange, notice: 'Exchange was successfully created.' }
        format.json { render :show, status: :created, location: @exchange }
      else
        format.html { render :new }
        format.json { render json: @exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exchanges/1
  # PATCH/PUT /exchanges/1.json
  def update
    respond_to do |format|
      if @exchange.update(exchange_params)
        format.html { redirect_to @exchange, notice: 'Exchange was successfully updated.' }
        format.json { render :show, status: :ok, location: @exchange }
      else
        format.html { render :edit }
        format.json { render json: @exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exchanges/1
  # DELETE /exchanges/1.json
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
      @exchange = Exchange.find(params[:id])
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
      # binding.pry
    end

    def sufficient_funds?
      n = 1
      if @order == "Place Sell Order"
        n = -1
      end
      @coin_1_quantity_total  = @coin_1.coin_quantity + (@order_quantity *
                                n)
      @coin_2_quantity_total = @coin_2.coin_quantity - ((@price *
                                @order_quantity) * n)

      (@coin_1_quantity_total >= 0.00) && (@coin_2_quantity_total >= 0.00)
    end

    def execute_order
      @coin_1.update_attributes!({coin_quantity: @coin_1_quantity_total})        

      @coin_2.update_attributes!({coin_quantity: @coin_2_quantity_total})        
    end
    
    def create_wallet_if_missing
      unless @coin_1  
        Wallet.create!({coin_type:  @coin_1_ticker, 
                    coin_quantity: 0,
                    exchange_id: @exchange.id, 
                    player_id: current_player.id,
                    public_key: 
                    "#{@coin_1_ticker}#{current_player.id}#{@exchange.id}",
                    league_id: 1
                  })
      end
      unless @coin_2
        Wallet.create!({coin_type:  @coin_2_ticker, 
                      coin_quantity: 0,
                      exchange_id: @exchange.id, 
                      player_id: current_player.id,
                      public_key: 
                      "#{@coin_2_ticker}#{current_player.id}#{@exchange.id}",
                      league_id: 1
                    })
      end
      find_and_set_coins      
    end
end
