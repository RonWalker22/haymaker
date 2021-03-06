class LeaguesController < ApplicationController
  before_action :check_signed_in
  before_action :set_league_variables, except: [:create, :new, :index, :join,
                                                :past, :current]
  before_action :set_league, only: [:join]
  before_action :check_actions_legal, only: [:deleverage, :swing, :bet, :shield]
  before_action :check_swing_deadline, only: [:swing, :show]
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
    round_steps = {'1' => 1, '6' => 2, '12' => 4,
                  '28' => 7, '84' => 14, '360' => 30 }
    round_options = {'1' => 1, '6' => 3, '12' => 3,
                    '28' => 4, '84' => 6, '360' => 12}
   rounds = 1
   if params[:game_mode].downcase == 'slugfest'
     rounds = round_options[params[:duration]]
   end
   start_date = league_params[:start_date].to_datetime.end_of_day + 1.second
   round_end  = start_date - 1.second
   end_date   = league_params[:start_date].to_datetime + params[:duration].to_i.days
   end_date   = end_date.end_of_day
   swing_by   = Time.now
   password = league_params[:password].empty? ? '123' : league_params[:password]

    @league = League.new( name: league_params[:name],
                          commissioner_id: league_params[:commissioner_id].to_i,
                          start_date: start_date,
                          end_date: end_date,
                          round_end: round_end,
                          rounds: rounds,
                          private: params[:community].downcase == 'private',
                          mode:  params[:game_mode].upcase,
                          password: password,
                          late_join: params[:late_join] == "true",
                          round_steps: round_steps[params[:duration]],
                          swing_by: swing_by
                         )
    respond_to do |format|
      if @league.save
        ExchangeLeague.create! league_id: @league.id, exchange_id: 1
        flash[:notice] = 'League was successfully created.'
        @league_user = LeagueUser.create!({league_id:@league.id,
                                  user_id:current_user.id})
        create_usdt_wallets
        create_set_up_balance
        format.html { redirect_to @league }
        format.json { render :show, status: :created, location: @league }
      else
        flash.now[:alert] = 'League was not created.'
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
        flash.now[:alert] = 'League was not updated.'
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
      flash[:alert] = "This league is no longer accepting new players."
      return redirect_to leagues_url
    elsif @league.start_date.past? && !@league.late_join?
      flash[:alert] = "This league does not accept late joiners."
      return redirect_to leagues_url
    elsif @league.private?
      if current_user.received_league_invites.find_by league_id:@league.id
        nil
      elsif password_param[:password].downcase != @league.password.downcase
        flash[:alert] = "That password is incorrect."
        return redirect_to league_path @league
      end
    end

    @new_league_user = LeagueUser.new({user_id:current_user.id,
                      league_id: @league.id})
    if @new_league_user.save
      accpet_league_invite
      create_usdt_wallets
      create_set_up_balance
      flash[:notice] = "You have successfully joined the #{@league.name} league."
    else
      flash[:alert] = 'You have aleady joined this league.'
    end
    redirect_to league_path(@league)
  end

  def reset_funds
    league = League.find(1)
    league_user = LeagueUser.find_by league_id: 1, user_id: current_user.id
    wallets = Wallet.where league_user_id: league_user.id
    wallets = Wallet.where league_user_id: league_user.id

    wallets.each do |wallet|
      if wallet.coin_type == 'USDT'
        wallet.update_attributes total_quantity: league.starting_balance,
                                 reserve_quantity: 0
      else
        wallet.destroy
      end
      flash[:notice] = "Funds have been reset."
    end

    redirect_to league_path(1)
  end

  def set_up
    create_set_up_balance

    redirect_to league_path(@league)
  end

  def leave
    if @league.start_date.past?
      flash[:alert] = "You are unable to leave a league which has already started."
      return redirect_to league_url(@league)
    end

    if @league_user.destroy
      flash[:notice] = "You have left the #{@league.name} league."
    end
    redirect_to leagues_path
  end

  def deleverage
    end_bet @league_user
    redirect_to league_path @league
  end

  def swing
    setup_swing_params
    if fight_illegal?
      flash[:alert] = "Fistfight was unsuccessful due to your active shield."
    else
      start_fist_fight
    end
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
    if Bet.find_by league_user: @league_user.id
      flash[:alert] = "#{@leverage.size}x leverage was unsuccessful.
                        You can't use leverage more than once per league."
    elsif @league.mode != 'Slugfest'
      flash[:alert] = "#{@leverage.size}x leverage was unsuccessful.
                        Leverage is not available in this game mode."
    else
      baseline = @users_stats[@league_user][:cash]
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
        flash[:alert] = "#{@leverage.size}x leverage was unsuccessful."
      end
    end
    redirect_to league_path @league
  end

  def balances
    @balances = []
    @league_user.wallets.where(league_user: @league_user).each do |w|
      next if w.total_quantity == 0
      if w.coin_type == 'USDT'
        usdt_price = 1
      else
        usdt_price = Ticker.find_by(pair:"#{w.coin_type}-USDT").price.to_f
      end
      usdt_value = (w.total_quantity * usdt_price).round 2

      @balances.push(symbol: w.coin_type,
                     quantity: w.total_quantity,
                     value: usdt_value)
    end
  end

  def shield
    unless @league_user.blocks > 0
      return flash[:alert] = "Shield unsuccessful. You don't have any shield
                              available."
    end

    @league_user.shield = true
    @league_user.decrement 'blocks'
    if @league_user.save
      flash[:success] = "Shield is now active."
    end

    redirect_to league_path @league
  end

  def auto_shield
    if @league_user.blocks > 0
      @league_user.auto_shield = true
      @league_user.decrement 'blocks'
      @league_user.save
      flash[:notice] = "Auto shield is now active. You will be shielded from
                        all fistfights during the next round."
    else
      flash[:alert] = "Auto shield was unsuccessful. You don't have any shields
                        remaining."
    end
    redirect_to league_path @league
  end

  private
    def set_league_variables
      set_league
      set_league_user
      set_tickers
      set_league_wallets
      set_users_stats
    end

    def check_user_alive
      if !@league_user.alive?
        flash[:alert] = "You have been knocked out of this league and are no
                                  longer able to access any league actions."
        return redirect_to @league
      end
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

    def set_tickers
      @tickers = Ticker.all
    end

    def set_users_stats
      @users_stats = leaderboards
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
                              coin_type: 'USDT')
      wallet.total_quantity = @league.starting_balance

      if wallet.save
        league_user.update_attributes set_up: true, ready: true
      end
    end

    def create_usdt_wallets
      league_user = @league_user || @new_league_user
      Wallet.create!(league_user_id: league_user.id,
                      exchange_id: 1,
                      coin_type: 'USDT',
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
        @league_user.increment 'blocks'
        @league_user.shield = true
        @league_user.save
        @target.shield = true
        @target.increment 'blocks'
        @target.save
        flash[:notice] = "Fistfight has begun."
      else
        flash[:alert] = "Fistfight was unable to start."
      end
    end

    def fight_illegal?
      shields_active? && target_dead?
    end

    def shields_active?
      @league_user.shield? || @target.shield?
    end

    def target_dead?
      !@target.alive?
    end

    def check_actions_legal
      if !@league_user.alive?
        flash[:alert] = "You have been knocked out of this league and are no
                                  longer able to access any league actions."
        return redirect_to @league
      elsif @league.start_date.future? || @league.end_date.past?
        flash[:alert] = "League actions are currently unavailable."
        return redirect_to @league
      end
    end

    def check_swing_deadline
      if @league.swing_by.past? && @league.active?
        @league.league_users.each do |league_user|
          next if league_user.shield?
          league_user.update_attributes shield:true
        end
      end
    end
end
