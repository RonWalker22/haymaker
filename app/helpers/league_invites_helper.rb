module LeagueInvitesHelper
  def available_invite_leagues(user)
    league_invites = LeagueInvite.all
    user_leagues = user.leagues
    available_leagues = []
    League.all.each do |league|
      user_in_league = user_leagues.any? do |user_league|
        user_league.id == league.id
      end
      current_user_in_league = current_user.leagues.any? do |user_league|
        user_league.id == league.id
      end
      user_already_invite = league_invites.any? do |invite|
        invite.receiver_id == user.id && invite.league_id == league.id
      end

      if !user_in_league && current_user_in_league && !user_already_invite
        available_leagues << league
      end
    end
    available_leagues
  end
end
