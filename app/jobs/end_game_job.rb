class EndGameJob < ApplicationJob
  include LeaguesHelper
  queue_as :default
  def perform(league)
    final_btce(league)
  end
end
