module LeaguesHelper

  def final_btce(league)
    league.users.all.each do |user|
      league_user = LeagueUser.find_by league_id: league.id, user_id: user.id
      index = leaderboards(league).index {|hash| hash[user.name]} + 1
      league_user.rank = index
      league_user.btce = leaderboards(league)[index - 1].values.first.to_f
      league_user.save
    end
  end

  def leaderboards(league)
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

  private

    def total_btc
      arr = []

      @user.wallets.where(coin_type: 'BTC', league_user_id: @league_user.id).each do |w|
        arr << w.coin_quantity
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
          hash["#{w.coin_type}#{w.exchange_id}"][0] += w.coin_quantity
        else
          hash["#{w.coin_type}#{w.exchange_id}"] =
                                  [w.coin_quantity, ticker.price]
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
