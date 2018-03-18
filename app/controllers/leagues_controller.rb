class LeaguesController < ApplicationController
  before_action :set_league, only: [:show, :edit, :update, :destroy]

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
    @league = League.new(league_params)
    respond_to do |format|
      if @league.save
        flash[:notice] = 'League was successfully created.'
        @leaguePlayer = LeaguePlayer.create!({league_id:@league.id, 
                                  player_id:current_player.id})
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
    new_palyer = LeaguePlayer.new({player_id:current_player.id,
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
    wallets = Wallet.where player_id: current_player, league_id: 1 

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
        :start_date, :player_id, :end_date, :rounds, :exchange_risk,
        :exchange_fees, :high_be_score, :public_keys, :instant_deposits_withdraws, :lazy_picker)
    end
end
