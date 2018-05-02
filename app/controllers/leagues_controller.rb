class LeaguesController < ApplicationController
  before_action :set_league, only: [:show, :edit, :update, :destroy]
  before_action :user_signed_in?, only: [:show, :edit, :update, :destroy,
                                          :order, :index]

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
    @league = League.new(league_params.slice(:name, :user_id, :start_date, :end_date))
    respond_to do |format|
      if @league.save
        create_exchange_league_table
        flash[:notice] = 'League was successfully created.'
        @leagueUser = LeagueUser.create!({league_id:@league.id,
                                  user_id:current_user.id})
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
      format.html { redirect_to leagues_url}
      format.json { head :no_content }
    end
  end

  def join
    new_palyer = LeagueUser.new({user_id:current_user.id,
                      league_id: params[:league]})
    if new_palyer.save
      flash[:notice] = 'You have successfully joined this league.'
    else
      flash[:notice] = 'You have aleady joined this league.'
    end
      redirect_to league_path(params[:league])
  end

  def request_reset
  league = League.find(params[:league])
    if league.id == 1
      # flash[:notice] = 'League was successfully updated.'
      flash[:reset_funds] =
                  'Are you sure you want to reset your practice league funds?'
      respond_to do |format|
        format.html { redirect_to league_url(league.id)}
        format.json { render :show, status: :ok, location: league }
      end
    else
      respond_to do |format|
        flash[:notice] = "Funds can only be reset in the practice league."
        format.html { redirect_to league_url(league.id) }
        format.json { render json: @league.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  def reset_funds
    wallets = Wallet.where user_id: current_user, league_id: 1

    wallets.each do |wallet|
      if wallet.coin_type == 'BTC'
        wallet.update_attributes coin_quantity: 100.00
      else
        wallet.update_attributes coin_quantity: 0
      end
      flash[:notice] = 'Funds in Practice League have been reset.'
    end

    redirect_to league_url(1)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_league
      @league = League.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def league_params
      params.require(:league).permit(:name, :entry_fee, :commissioner,
        :start_date, :user_id, :end_date, :rounds,
        :exchange_fees, :public_keys, :"Binance Exchange", :"Gemini Exchange",
        :"Hitbtc Exchange", :"GDAX Exchange")
    end

    def create_exchange_league_table
      Exchange.all.each do |x|
        # binding.pry
        if league_params["#{x.name} Exchange"].to_i == 1
          ExchangeLeague.create! league_id: @league.id, exchange_id: x.id
        end
      end
    end
end
