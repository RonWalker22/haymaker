# require 'pry'
class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  before_action :check_permissions, only: [:edit, :update, :destroy]

  # GET /players
  # GET /players.json
  def index
    @players = Player.all
  end

  # GET /players/1
  # GET /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)
    if @player.save
      log_in @player
      flash[:notice] = 'Player was successfully created.'
      redirect_to leaderboards_path
    else
      render :new
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        flash[:notice] = 'Player was successfully updated.'
        format.html { redirect_to @player}
        format.json { render :show, status: :ok, location: @player }
      else
        flash.now[:notice] = 'Update failed. All fields are required.'
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      flash[:notice] = 'Player was successfully destroyed.'
      format.html { redirect_to players_url}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:username, :password,
        :password_confirmation, :email)
    end

    def check_permissions
      if !logged_in?
        store_location
        flash[:notice] = 'Please log in.'
        redirect_to login_path
      elsif !current_player?(@player)
        flash[:notice] = "You have not been granted access to that section."
        redirect_to leaderboards_path
      end
    end
end
