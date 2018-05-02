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
end
