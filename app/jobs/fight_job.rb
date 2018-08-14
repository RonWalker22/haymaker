class FightJob < ApplicationJob
  include LeaguesHelper
  queue_as :default

  def perform
    start_fist_fight
  end

  private

  def start_fist_fight
    @league = League.find(1)
    @league.league_users.each_with_index do |league_user, i|
      @baseline = [7_000, 12_000, 8_000, 9_000, 11_000].sample
      next unless i.even? || i == 40
      @league_user     = LeagueUser.find(i + 1)
      @league_defender = LeagueUser.find(i + 2)

      fistfight = Fistfight.new(
                                attacker_id: @league_user.id,
                                defender_id: @league_defender.id,
                                round: 2,
                                league_id: @league.id
      )

      if fistfight.save
        @league_user.shield = true
        @league_user.save
        @league_defender.shield = true
        @league_defender.save
      end
    end

    LeagueUser.all.each do |user|
      user.points = @baseline
      user.save
    end
  end
end
