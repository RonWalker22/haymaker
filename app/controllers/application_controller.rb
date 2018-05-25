class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :switch_exchanges

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

  def check_signed_in
    if !user_signed_in?
      flash[:notice] = "You must be signed in to access that area."
      return redirect_to(new_user_session_path)
    end
  end
end
