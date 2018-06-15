class UsersController < ApplicationController
  before_action :check_signed_in, only: [:show]
  before_action :set_user, only: [:show]

  def index
    @users = User.all
  end

  def show
  end

  def current_user_home
    redirect_to current_user
  end

  def admin
    if current_user.admin?
      Thread.new do
        GetTickersJob.perform_later
        sleep(10)
        GetTickerPricesJob.perform_now
        flash[:notice] = 'Tickers live!'
      end
    end
    redirect_back fallback_location: root_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user)
    end
end
