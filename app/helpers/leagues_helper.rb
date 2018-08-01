module LeaguesHelper
  def final_stats(league)
    final_rankings = leaderboards

    final_rankings.each_with_index do |user_stats, index|
      league_user        = LeagueUser.find user_stats[:id]
      league_user.rank   = index + 1
      league_user.points = user_stats[:cash]
      league_user.alive  =  false
      league_user.save
    end
  end

  def update_stats(league)
    current_rankings = leaderboards

    current_rankings.each_with_index do |user_stats, index|
      league_user        = LeagueUser.find user_stats[:id]
      if league_user.alive
        league_user.points   = user_stats[:cash]
        league_user.save
      end
    end
  end

  def leaderboards
    arr = []
    users = @league.users.order(:id)
    @league.league_users.order(:user_id).all.each_with_index do |league_user, index|
      @temp_user        = users[index]
      @temp_league_user = league_user
      total_btc_estimate = alt_coins_estimate + total_btc
      arr << { btce: total_btc_estimate,
               id: @temp_league_user.user_id,
               league_user: @temp_league_user,
               user: @temp_user}
    end
    arr.sort_by! { |hash| hash.values}
    arr.reverse!
    arr.each_with_index do |hash, index|
      hash[:cash] = (hash[:btce].to_f * @btc_price).round 2
      hash[:rank] = index + 1
    end
    arr
  end

  def portfolio_value(league_user, league = nil, btc_price = nil)
    leaderboards.each do |hash|
       return hash[:cash] if hash[:id] == league_user.user_id
    end
  end

  def current_btce(id, league, btc_price)
    leaderboards.each do |hash|
       return hash[:btce] if hash[:id] == id
    end
  end

  def current_rank(id)
    leaderboards.each do |hash, index|
       return hash[:rank] if hash[:id] == id
    end
  end

  def round_performance(l_user, league = nil, btc_price = nil)
    @league ||= league
    @league_wallets ||= @league.wallets
    @btc_price ||= btc_price
    @tickers = Ticker.all
    results = ((portfolio_value(l_user, league, btc_price) - l_user.points ) / l_user.points)
    (results * 100).round 2
  end

  def users_performance
    fistfights = @league.fistfights
    arr        = []

    leaderboards.each do |hash|
      fistfights.each do |ff|
        if hash[:id] == ff.attacker_id || hash[:id] == ff.defender_id
          fistfight = ((hash[:cash] - hash[:league_user].points ) / hash[:league_user].points)
          fistfight = (fistfight * 100).round 2
          arr << { id: hash[:id], fistfight: fistfight,
                  user: hash[:user], league_user: hash[:league_user] }
          break
        end
      end
    end
    arr
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
