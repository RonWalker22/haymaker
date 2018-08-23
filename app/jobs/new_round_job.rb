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
      @league_wallets = @league.wallets
      @users_stats = leaderboards
      @fistfights = @league.fistfights.where(active:true)
      end_bets if @league.round == @league.rounds
      end_fistfights
      update_stats
      @alive_users = @league.league_users.where alive:true
      update_shields
      if @league.round < @league.rounds
        establish_baselines
        @league.round += 1
        @league.round_end += @league.round_steps.days
        @league.swing_by = @league.round_end - (@league.round_steps / 2).days
        @league.save
      else
        end_game
      end
    end
  end

  private

  def update_shields
    @alive_users.each do |league_user|
      if league_user.auto_shield?
        league_user.shield = true unless league_user.shield?
        league_user.auto_shield = false
      else
        league_user.shield = false if league_user.shield?
      end
      league_user.save
    end
  end

  def establish_baselines
    @alive_users.each do |league_user|
      league_user.baseline = league_user.score
    end
  end

  def end_fistfights
    @fistfights.each do |fistfight|
      update_fight_performance(fistfight)
      decide_round_champ(fistfight)
      fistfight.active = false
      fistfight.save
      update_loser_stats
    end
  end

  def update_loser_stats
    @fight_loser.portfolio = @users_stats[@fight_loser][:cash]
    @fight_loser.score     = @users_stats[@fight_loser][:score]
    @fight_loser.rank      = -1
    @fight_loser.alive     = false
    @fight_loser.save
  end

  def end_game
    @alive_users = @league.league_users.where alive:true
    update_stats
    decide_champ
    knockout_losers
    @league.active = false
    @league.save
  end

  def knockout_losers
    @alive_users.where(champ:false).each do |league_user|
      league_user.alive = false
      league_user.save
    end
  end

  def end_bets
    @alive_users.each do |league_user|
      end_bet league_user
    end
  end

  def decide_champ
    max_score = @alive_users.maximum("score")
    if max_score
      champs = @alive_users.where score:max_score
      champs.each do |chachampion|
        chachampion.champ = true
        chachampion.save
      end
    end
  end

  def update_fight_performance(ff)
      attcker     = LeagueUser.find ff.attacker_id
      defender    = LeagueUser.find ff.defender_id
      ff.attacker_performance = @users_stats[attcker][:performance]
      ff.defender_performance = @users_stats[defender][:performance]
      #ff.save
  end

  def decide_round_champ(ff)
    if ff.attacker_performance > ff.defender_performance
      @fight_winner = LeagueUser.find (ff.attacker_id)
      @fight_loser  = LeagueUser.find ff.defender_id
    else
      @fight_winner = LeagueUser.find ff.defender_id
      @fight_loser  = LeagueUser.find ff.attacker_id
    end
  end

  def update_stats
    @users_stats.each do |league_user, stats|
      next unless league_user.alive?
      league_user.rank      = stats[:rank]
      league_user.score     = stats[:score]
      league_user.portfolio = stats[:cash]
      league_user.save
    end
  end
end
