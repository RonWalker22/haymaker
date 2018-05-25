class LeagueInvitesController < ApplicationController
  before_action :check_signed_in
  before_action :set_up_invite_variables, only: [:create]
  before_action :set_up_league_invite, only: [:decline, :accept]

  def create
    if already_invited_to_league?
      flash[:notice] = "#{@receiver.name} has already been invited to the
                        #{@league.name} league."
    else
      league_invite = LeagueInvite.new({league_id: @league.id,
                                            receiver_id: @receiver.id,
                                            sender_id: @sender.id})
      if league_invite.save
        flash[:notice] = "You have successfully invited #{@receiver.name} to join
                          the #{@league.name} league."
      else
        flash[:notice] = "The invitation was unsuccessful."
      end
    end
    redirect_to user_path(@receiver)
  end

  def decline
    @league_invite.status = "declined"
    if @league_invite.save
      flash[:notice] = "You have declinded
                        #{User.find(@league_invite.sender_id).name}'s invitation
                        to join the
                        #{League.find(@league_invite.league_id).name} league."
    end
    redirect_to user_path(@league_invite.receiver)
  end

  def destory
  end

  private

    def set_up_invite_variables
      @league = League.find(params[:id])
      @sender = User.find(params[:sid])
      @receiver = User.find(params[:rid])
    end

    def set_up_league_invite
      @league_invite = LeagueInvite.find(params[:lid])
    end

    def already_invited_to_league?
      LeagueInvite.all.any? do |invite|
        invite.receiver_id == @receiver.id && invite.league_id == @league.id
      end
    end
end
