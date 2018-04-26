class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :switch_exchanges
  include SessionsHelper


  def check_logged_in_and_premissions

  end



  def check_permissions
    if check_logged_in
      return
    elsif current_player.admin?
      return
    elsif !current_player?(@player)
      flash[:notice] = "You have not been granted access to that section."
      redirect_to leaderboards_path
    end
  end

  def check_logged_in
    if !logged_in?
      store_location
      flash[:notice] = 'Please log in.'
      redirect_to login_path
    end
  end
  private

  def switch_exchanges(x_id)
    case params[:action]
    when 'balances'
      balances_path(params[:id], x_id, params[:cid])
    when 'withdrawal'
      withdrawal_path(params[:id], x_id, params[:cid])
    when 'show'
      trade_path(params[:id], x_id, :p => 'ETH-BTC')
    when 'transaction_history'
      transaction_history_path(params[:id], x_id, params[:cid])
    end
  end
end
