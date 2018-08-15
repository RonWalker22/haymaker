class DestroyFightsJob < ApplicationJob
  queue_as :default

  def perform
    destroy_fights
    destroy_bets
    reset_league_users
    go_to_round_2
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
      lu.update_attributes alive:true, leverage_points:0, rank: 0, shield: false, blocks:0
    end
  end

  def go_to_round_2
    League.first.update_attributes round:2
  end
end
