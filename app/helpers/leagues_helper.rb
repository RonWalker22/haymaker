module LeaguesHelper
  def leaderboards
    @tickers = Ticker.all
    hash = {}
    users = @league.users.order(:id)
    @league.league_users.order(:user_id).all.each_with_index do |league_user, index|
      @temp_user        = users[index]
      @temp_league_user = league_user
      total_btc_estimate = alt_coins_estimate + total_btc
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
      arr = []
      user        = @temp_user        || @user
      league_user = @temp_league_user || @league_user
      @user_wallets.each do |user_wallet|

        if user_wallet.coin_type == 'BTC'
          @btc_wallet = user_wallet
          break
        end
      end
      @btc_wallet.total_quantity
    end

    def alt_coins_estimate
      hash          = {}
      arr           = []
      user          = @temp_user        || @user
      league_user   = @temp_league_user || @league_user
      @user_wallets = []
      @league_wallets.each do |league_wallet|
        if league_wallet.league_user_id == league_user.id
          @user_wallets << league_wallet
        end
      end


      @user_wallets.each do |w|
        base_currency = w.coin_type
        next if base_currency == 'BTC'
        quote_currency = 'BTC'


        @tickers.each do |ticker|
          if ticker.base_currency == base_currency && ticker.quote_currency == 'BTC'
            @ticker = ticker
            break
          end
        end

        if hash["#{w.coin_type}#{w.exchange_id}"]
          hash["#{w.coin_type}#{w.exchange_id}"][0] += w.total_quantity
        else
          hash["#{w.coin_type}#{w.exchange_id}"] =
                                  [w.total_quantity, @ticker.price]
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
