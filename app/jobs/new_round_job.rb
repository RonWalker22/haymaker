class NewRoundJob < ApplicationJob
  include LeaguesHelper
  queue_as :default

  def perform
    @btc_price = Ticker.find_by(pair:"BTC-USDT", exchange_id: 1).price.to_f
    # leagues = League.all.where('round_end <= :now AND active = true AND
    #                             round <= rounds', :now => Time.now)
    leagues = League.all.where active: true
    leagues.each do |league|
      @league = league
      @league.league_users.where(shield:true).each do |league_user|
        league_user.update_attributes shield:false
      end
      end_fistfights if @league.round > 1
      update_stats(league)
      if @league.round < @league.rounds
        @league.round += 1
        @league.round_end += @league.round_steps.days
        @league.save
      end
    end
  end

  private

  def end_fistfights
    fistfights = @league.fistfights.where('round = :league_round',
                                          league_round: @league.round)
    if fistfights.count > 0
      fistfights.each do |fistfight|
        @attacker = LeagueUser.find(fistfight.attacker_id)
        @defender = LeagueUser.find(fistfight.defender_id)
        knockout_loser
        fistfight.attacker_performance = @attacker_performance
        fistfight.defender_performance = @defender_performance
        fistfight.active = false
        fistfight.save
      end
    end
  end

  def knockout_loser
    @attacker_performance = round_performance(@attacker, @league, @btc_price )
    @defender_performance = round_performance(@defender, @league, @btc_price )

    if @attacker_performance > @defender_performance
      @winner = @attacker
      @loser  = @defender
    else
      @winner = @defender
      @loser  = @attacker
    end

    @loser.alive = false
    @loser.points = portfolio_value(@loser)
    @loser.rank = -1
    @loser.save

    @winner.increment! 'blocks'
    @winner.points = portfolio_value(@loser)
    @winner.rank = current_rank @winner.user_id
    @winner.save
  end
end
