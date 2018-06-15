class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :switch_exchanges
  helper_method :current_rank
  helper_method :leader_boards

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

  def current_rank(user, league)
    leader_boards(league).index {|hash| hash[user.name]} + 1
  end

  def leader_boards(league)
    @league = league
    arr = []
    @league.users.all.each do |user|
      @user = user
      @league_user = LeagueUser.find_by league_id: @league.id, user_id: @user.id
      total_btc_estimate = alt_coins_estimate + total_btc
      arr << { user.name =>  total_btc_estimate }
    end
    arr.sort_by! { |hash| hash.values}
    arr.reverse!
    arr.each do |hash|
      hash.each {|k,v| hash[k] = '%.8f' % v }
    end
    arr
  end

  def total_btc
    arr = []

    @user.wallets.where(coin_type: 'BTC', league_user_id: @league_user.id).each do |w|
      arr << w.total_quantity
    end
    arr.empty? ? 0 : arr.reduce(:+).round(8)
  end

  def alt_coins_estimate
    hash = {}
    arr = []
    @user.wallets.where(league_user_id: @league_user.id).each do |w|
      base_currency = w.coin_type
      quote_currency = 'BTC'
      ticker = Ticker.find_by base_currency: base_currency,
                              quote_currency: 'BTC',
                              exchange_id: w.exchange_id
      next if ticker.nil?

      if hash["#{w.coin_type}#{w.exchange_id}"]
        hash["#{w.coin_type}#{w.exchange_id}"][0] += w.total_quantity
      else
        hash["#{w.coin_type}#{w.exchange_id}"] =
                                [w.total_quantity, ticker.price]
      end
    end
    hash.each do |k, v|
      hash[k][2] = v[0] * v[1]
      arr << v[2]
      hash[k][0] = '%.8f' % v[0]
      hash[k][1] = '%.8f' % v[1]
      hash[k][2] = '%.8f' % v[2]
    end
    arr.empty? ? 0 : arr.reduce(:+).round(8)
  end
end
