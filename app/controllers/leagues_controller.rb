class LeaguesController < ApplicationController
  before_action :check_signed_in
  before_action :set_league_variables, except: [:create, :new, :index, :join,
                                                :past, :current]
  before_action :set_league, only: [:join]
  include LeaguesHelper

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
    league_params
    puts ">>>>>-------->>>>#{params}"
    round_steps = {'1' => 1, '6' => 2, '12' => 4,
                  '28' => 7, '84' => 14, '360' => 30 }
    rounds = {'1' => 1, '6' => 3, '12' => 3,
                  '28' => 4, '84' => 6, '360' => 12}

   start_date = league_params[:start_date].to_datetime.midday
   round_end  = league_params[:start_date].to_datetime + round_steps[params[:duration]].days
   round_end  = round_end.end_of_day
   end_date   = league_params[:start_date].to_datetime + params[:duration].to_i.days
   end_date   = end_date.end_of_day

    @league = League.new( name: league_params[:name],
                          commissioner_id: league_params[:commissioner_id].to_i,
                          start_date: start_date,
                          end_date: end_date,
                          round_end: round_end,
                          rounds: rounds[params[:duration]],
                          private: params[:community].downcase == 'private',
                          mode:  params[:game_mode],
                          password: league_params[:password],
                          late_join: params[:late_join] == "true",
                          round_steps: round_steps[params[:duration]]
                         )
    respond_to do |format|
      if @league.save
        ExchangeLeague.create! league_id: @league.id, exchange_id: 1
        flash[:notice] = 'League was successfully created.'
        @league_user = LeagueUser.create!({league_id:@league.id,
                                  user_id:current_user.id})
        create_btc_wallets
        create_set_up_balance
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
    if @league.start_date.past? && @league.round > 1
      flash[:notice] = "This league is no longer accepting new players."
      return redirect_to leagues_url
    elsif @league.start_date.past? && !@league.late_join?
      flash[:notice] = "This league does not accept late joiners."
      return redirect_to leagues_url
    elsif @league.private?
      unless password_param[:password].downcase == @league.password.downcase
        flash[:alert] = "That password is incorrect."
        return redirect_to leagues_url
      end
    end

    @new_league_user = LeagueUser.new({user_id:current_user.id,
                      league_id: @league.id})
    if @new_league_user.save
      accpet_league_invite
      create_btc_wallets
      create_set_up_balance
      flash[:notice] = "You have successfully joined the #{@league.name} league."
    else
      flash[:notice] = 'You have aleady joined this league.'
    end
    redirect_to league_path(@league)
  end

  def reset_funds
    league = League.find(1)
    league_user = LeagueUser.find_by league_id: 1, user_id: current_user.id
    wallets = Wallet.where league_user_id: league_user.id

    wallets.each do |wallet|
      if wallet.coin_type == 'BTC'
        wallet.update_attributes total_quantity: league.starting_balance
      else
        wallet.update_attributes total_quantity: 0
      end
      flash[:notice] = 'Funds in Practice League have been reset.'
    end

    redirect_to league_path(1)
  end

  def set_up
    create_set_up_balance

    redirect_to league_path(@league)
  end

  def leave
    if @league.start_date.past?
      flash[:notice] = "You are unable to leave a league which has already started."
      return redirect_to league_url(@league)
    end

    if @league_user.destroy
      flash[:notice] = "You have left the #{@league.name} league."
    end
    redirect_to leagues_path
  end

  def deleverage
    bet = @league_user.bets.last
    leverage = Leverage.find (@league_user.bets.last.leverage_id)
    current_cash_value = portfolio_value @league_user
    if bet && bet.active
      bet.active = false
      @size = leverage.size.to_i - 1
      @league_user.alive = false if current_cash_value <= bet.liquidation
      @league_user.leverage_points += ((current_cash_value - bet.baseline) * @size).round(2)
      @league_user.save
      bet.post_value = current_cash_value
      if bet.save
        flash[:notice] = "Leverage has been successfully deactivated."
      end
    end
    redirect_to league_path @league
  end

  def swing
    setup_swing_params
    start_fist_fight
    redirect_to league_path @league
  end

  def current
    @leagues = League.all
  end

  def past
    @leagues = League.all
  end

  def bet
    @leverage =  Leverage.find_by size: params[:size]
    @league_user = LeagueUser.find_by(league_id: @league.id,
                                      user_id: current_user.id)

    baseline = portfolio_value @league_user
    new_bet = Bet.new(
                  leverage_id: @leverage.id,
                  league_user_id: @league_user.id,
                  baseline: baseline,
                  liquidation: baseline - (@leverage.liquidation * baseline),
                  round: @league.round,
                  post_value: -1)
    if new_bet.save
      flash[:notice] = "#{@leverage.size}x leverage is now active."
    else
      flash[:notice] = "#{@leverage.size}x leverage was unsuccessful."
    end
    redirect_to league_path @league
  end

  def balances
  end

  def shield
    unless @league_user.blocks > 0
      return flash[:notice] = "Shield unsuccessful. You don't have any blocks available."
    end

    @league_user.shield = true
    if @league_user.save
      @league_user.decrement! 'blocks'
      flash[:success] = "Shield is now active. You are shielded from participating in a fistfight in this round."
    end

    redirect_to league_path @league
  end

  private
    def set_league_variables
      set_league
      set_league_user
      set_btc_price
      set_tickers
      set_league_wallets
    end

    def set_league
      @league = League.find(params[:id])
    end

    def set_btc_price
      @btc_price = Ticker.find_by(pair:"BTC-USDT", exchange_id: 1).price.to_f
    end

    def set_league_user
      if current_user
        @league_user = LeagueUser.find_by(league_id: @league.id,
                                          user_id: current_user.id)
      end
    end

    def set_tickers
      @tickers = Ticker.all
    end

    def set_league_wallets
      @league_wallets = @league.wallets
    end

    def league_params
      params.require(:league).permit(:name, :entry_fee, :commissioner,
        :start_date, :user_id, :commissioner_id, :end_date, :rounds,
        :public_keys, :password, :game_mode, :community, :duration, :late_join)
    end

    def setup_params
      params.permit(:exchange_starter, :league)
    end

    def password_param
      params.permit(:password)
    end

    def setup_swing_params
      @target = LeagueUser.find_by user_id:punch_params[:target], league_id: @league.id
    end

    def punch_params
      params.permit(:punch, :target)
    end

    def leverage_params
      params.permit(:leverage_size)
    end

    def create_set_up_balance
      league_user = @league_user || @new_league_user
      wallet = Wallet.find_by(league_user_id: league_user.id,
                              coin_type: 'BTC')
      wallet.total_quantity = @league.starting_balance

      if wallet.save
        league_user.update_attributes set_up: true, ready: true
      end
    end

    def create_btc_wallets
      league_user = @league_user || @new_league_user
      Wallet.create!(league_user_id: league_user.id,
                      exchange_id: 1,
                      coin_type: 'BTC',
                      total_quantity: 0.00,
                      public_key: SecureRandom.hex(20)
                      )
    end

    def accpet_league_invite
      league_invite = LeagueInvite.find_by league_id: @league.id,
                                            receiver_id: current_user.id
      if league_invite
        league_invite.status = "accepted"
        league_invite.save
      end
    end

    def start_fist_fight
      fistfight = Fistfight.new(
                                attacker_id: @league_user.id,
                                defender_id: @target.id,
                                round: @league.round,
                                league_id: @league.id
      )

      if fistfight.save
        @league_user.udpate_attributes shield: true
        @target.udpate_attributes shield: true
        flash[:notice] = "Fistfight has begun."
      else
        flash[:alert] = "Fistfight was unable to start."
      end
    end
end
