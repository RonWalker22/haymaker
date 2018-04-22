module ExchangesHelper
  def strip_dash_from_pair
    pair = params[:p]
    mid_point = pair =~ /-/
    coin_1_ticker = []
    coin_2_ticker = []
    pair.size.times do |n|
      coin_1_ticker << pair[n] if n < mid_point
      coin_2_ticker << pair[n] if n > mid_point
    end
    "#{coin_1_ticker.join}#{coin_2_ticker.join}"
  end

  # def
  #
  # end
end
