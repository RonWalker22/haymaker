module LeaguesHelper
  def leaderboards
    #used to create less database queries
    @tickers = Ticker.all.where quote_currency: 'BTC'
    hash = {}
    users = @league.users.order(:id)
    @league.league_users.order(:user_id).all.each_with_index do |league_user, index|
      @temp_user        = users[index]
      @temp_league_user = league_user
      @user_wallets     = @temp_league_user.wallets
      hash[@temp_league_user] =  { btce: total_btc_estimate,
                                   user: @temp_user,
                                 }
    end

    hash.each do |league_user, stats|
      stats[:cash] = (stats[:btce].to_f * @btc_price).round 2
      stats[:score] = (stats[:cash] + league_user.net_bonus).round 2
      performance = (stats[:score] - league_user.baseline ) / league_user.baseline
      stats[:performance] = (performance * 100).round 2
      stats[:performance] = (performance * 100).round
    end

    hash = hash.sort_by { |_,stats| stats[:score] }.reverse.to_h

    hash.each_with_index do |arr, index|
      arr[1][:rank] = index + 1
    end

    hash
  end

  def end_bet(league_user)
    bet = league_user.bets.last
    if bet && bet.active
      leverage = Leverage.find (league_user.bets.last.leverage_id)
      current_cash_value = @users_stats[league_user][:cash]
      @size = leverage.size.to_i - 1
      league_user.alive = false if current_cash_value <= bet.liquidation
      league_user.net_bonus += ((current_cash_value - bet.baseline) * @size).round(2)
      league_user.save
      bet.post_value = current_cash_value
      bet.active = false
      bet.save
    end
  end

  private

    def total_btc
      btc = @user_wallets.find_by coin_type: 'BTC'
      btc.total_quantity
    end

    def total_usdt
      usdt = @user_wallets.find_by coin_type: 'USDT'
      if usdt
        usdt.total_quantity / @btc_price
      else
        0
      end
    end

    def alt_coins_estimate
      estimate = 0
      @user_wallets.each do |wallet|
        next if wallet.coin_type == 'BTC' || wallet.coin_type == 'USDT'

        ticker = @tickers.find_by base_currency: wallet.coin_type
        estimate += wallet.total_quantity * ticker.price
      end
      estimate
    end
    def total_btc_estimate
      total_btc + alt_coins_estimate + total_usdt
    end
end
