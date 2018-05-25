class LeaguesController < ApplicationController
  before_action :check_signed_in
  before_action :set_league_variables, except: [:create, :new, :index, :join]
  before_action :set_league, only: [:join]

  # GET /leagues
  # GET /leagues.json
  def index
    @leagues = League.all
  end

  # GET /leagues/1
  # GET /leagues/1.json
  def show
  end

  # GET /leagues/new
  def new
    @league = League.new
  end

  # GET /leagues/1/edit
  def edit
  end

  # POST /leagues
  # POST /leagues.json
  def create
    puts ">>>>>-------->>>>#{params}"
    @league = League.new(league_params.slice(:name, :commissioner_id,
                                              :start_date, :end_date))
    respond_to do |format|
      if @league.save
        create_exchange_league_table
        flash[:notice] = 'League was successfully created.'
        @league_user = LeagueUser.create!({league_id:@league.id,
                                  user_id:current_user.id})
        create_btc_wallets
        if @league.exchanges.count == 1
          create_set_up_balance
        end
        format.html { redirect_to @league }
        format.json { render :show, status: :created, location: @league }
      else
        flash.now[:notice] = 'League was not created.'
        format.html { render :new }
        format.json { render json: @league.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leagues/1
  # PATCH/PUT /leagues/1.json
  def update
    respond_to do |format|
      if @league.update(league_params)
        flash[:notice] = 'League was successfully updated.'
        format.html { redirect_to @league}
        format.json { render :show, status: :ok, location: @league }
      else
        flash.now[:notice] = 'League was not updated.'
        format.html { render :edit }
        format.json { render json: @league.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leagues/1
  # DELETE /leagues/1.json
  def destroy
    @league.destroy
    respond_to do |format|
      flash[:notice] = 'League was successfully destroyed.'
      format.html { redirect_to leagues_path}
      format.json { head :no_content }
    end
  end

  def join
    @new_league_user = LeagueUser.new({user_id:current_user.id,
                      league_id: @league.id})
    if @new_league_user.save
      accpet_league_invite
      create_btc_wallets
      if @league.exchanges.count == 1
        create_set_up_balance
      end
      flash[:notice] = 'You have successfully joined this league.'
    else
      flash[:notice] = 'You have aleady joined this league.'
    end
    redirect_to league_path(@league)
  end

  def request_reset
  league = League.find(params[:league])
    if league.id == 1
      # flash[:notice] = 'League was successfully updated.'
      flash[:reset_funds] =
                  'Are you sure you want to reset your practice league funds?'
      respond_to do |format|
        format.html { redirect_to league_path(league.id)}
        format.json { render :show, status: :ok, location: league }
      end
    else
      respond_to do |format|
        flash[:notice] = "Funds can only be reset in the practice league."
        format.html { redirect_to league_path(league.id) }
        format.json { render json: @league.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  def reset_funds
    league = League.find(1)
    league_user = LeagueUser.find_by league_id: 1, user_id: current_user.id
    wallets = Wallet.where league_user_id: league_user.id

    wallets.each do |wallet|
      if wallet.coin_type == 'BTC'
        wallet.update_attributes coin_quantity: league.starting_balance
      else
        wallet.update_attributes coin_quantity: 0
      end
      flash[:notice] = 'Funds in Practice League have been reset.'
    end

    redirect_to league_path(1)
  end

  def set_up
    create_set_up_balance

    redirect_to league_path(@league)
  end

  def request_leave
    flash[:request_leave] =
                "Are you sure you want to leave the #{@league.name} league?"
    respond_to do |format|
      format.html { redirect_to league_path(@league.id)}
      format.json { render :show, status: :ok, location: league }
    end
  end

  def leave
    league_user = LeagueUser.find_by(league_id: params[:id],
                                      user_id: params[:pid])
    if league_user.destroy
      flash[:notice] = "You have left the #{@league.name} league."
    end
    redirect_to leagues_path
  end

  private
    def set_league_variables
      set_league
      set_league_user
    end

    def set_league
      @league = League.find(params[:id])
    end

    def set_league_user
      if current_user
        @league_user = LeagueUser.find_by(league_id: @league.id,
                                          user_id: current_user.id)
      end
    end

    def league_params
      params.require(:league).permit(:name, :entry_fee, :commissioner,
        :start_date, :user_id, :commissioner_id, :end_date, :rounds,
        :exchange_fees, :public_keys, :"Binance Exchange", :"Poloniex Exchange",
        :"Bitfinex Exchange", :"GDAX Exchange", :exchange_starter)
    end

    def setup_params
      params.permit(:exchange_starter, :league)
    end

    def create_exchange_league_table
      Exchange.all.each do |x|
        if league_params["#{x.name} Exchange"].to_i == 1
          ExchangeLeague.create! league_id: @league.id, exchange_id: x.id
        end
      end
    end

    def create_set_up_balance
      league_user = @league_user || @new_league_user
      if @league.exchanges.count == 1
        wallet = Wallet.find_by(league_user_id: league_user.id,
                                coin_type: 'BTC')
      else
        exchange = Exchange.find(setup_params[:exchange_starter].to_i)
        wallet = Wallet.find_by(league_user_id: league_user.id,
                                exchange_id: exchange.id,
                                coin_type: 'BTC')
      end
      wallet.coin_quantity = @league.starting_balance

      if wallet.save
        league_user.update_attributes set_up: true, ready: true
        if exchange
          flash[:notice] =
            "Your starting balance have been set up at #{exchange.name}."
        end
      end
    end

    def create_btc_wallets
      @league.exchanges.each do |exchange|
        league_user = @league_user || @new_league_user
        Wallet.create!(league_user_id: league_user.id,
                        exchange_id: exchange.id,
                        coin_type: 'BTC',
                        coin_quantity: 0.00,
                        public_key: SecureRandom.hex(20)
                        )
      end
    end

    def accpet_league_invite
      league_invite = LeagueInvite.find_by league_id: @league.id,
                                            receiver_id: current_user.id
      if league_invite
        league_invite.status = "accepted"
        league_invite.save
      end
    end
end
