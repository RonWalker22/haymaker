class ResetLeaguesJob < ApplicationJob
  queue_as :default

  def perform
    destroy_fights
    destroy_bets
    reset_league_users
    reset_league
  end

  private

  def destroy_fights
    Fistfight.all.each { |fight| fight.destroy}
  end

  def destroy_bets
    Bet.all.each { |bet| bet.destroy}
  end

  def reset_league_users
    LeagueUser.all.each do |lu|
      lu.update_attributes alive:true, net_bonus:0, rank: 0, shield: false,
                           blocks:0, champ: false, score:0, portfolio:0,
                           auto_shield: false
    end
  end

  def reset_league
    League.first.update_attributes round:2, active:true
  end
end
