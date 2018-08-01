class EndGameJob < ApplicationJob
  include LeaguesHelper
  queue_as :default

  def perform
    # leagues = League.all.where('end_date <= :now AND active = true',
    #                             :now => Time.now)
    # leagues.each do |league|
    #   final_stats(league)
    #   league.active = false
    #   league.save
    # end
    puts "End Game finished"
  end
end
