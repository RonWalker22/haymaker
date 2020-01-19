module LeaguesHelper
  def leaderboards
    #used to create less database queries
    @tickers ||=  Ticker.all.where quote_currency: 'BTC'
    hash = {}
    users = @league.users.order(:id)
    @league.league_users.order(:user_id).all.each_with_index do |league_user, index|
      @temp_user        = users[index]
      @temp_league_user = league_user
      @user_wallets     = @temp_league_user.wallets
      hash[@temp_league_user] =  { usdte: total_usdte,
                                   user: @temp_user,
                                 }
    end

    hash.each do |league_user, stats|
      stats[:cash] = (stats[:usdte].to_f).round 2
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
    
    def total_usdte
      estimate = 0
      @user_wallets.each do |wallet|
        if wallet.coin_type == 'USDT'
          estimate += wallet.total_quantity
        else 
          usdt_ticker = @tickers.find_by base_currency: wallet.coin_type,                                      quote_currency: 'USDT'
          estimate += wallet.total_quantity * usdt_ticker.price
        end
      end
      estimate
    end
end
