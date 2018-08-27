class LiquidationJob < ApplicationJob
  include LeaguesHelper
  queue_as :default

  def perform

    League.where(active:true).each do |league|
      @league    = league
      @tickers   = Ticker.all.where quote_currency: 'BTC'
      @btc_price = Ticker.find_by(pair: 'BTC-USDT', exchange_id: 1).price.to_f
      league_users = @league.league_users.where(alive: true)

      league_users.each do |league_user|
        bet = league_user.bets.last
        if bet && bet.active
          current_cash_value = leaderboards[league_user][:cash]

          if current_cash_value <= bet.liquidation.to_f
            leverage = Leverage.find (league_user.bets.last.leverage_id)
            @size = leverage.size.to_i - 1
            league_user.alive = false
            league_user.net_bonus += ((current_cash_value - bet.baseline) * @size).round(2)
            league_user.save
            bet.post_value = current_cash_value
            bet.active = false
            bet.save
          end
        end
      end
    end

  end
end
