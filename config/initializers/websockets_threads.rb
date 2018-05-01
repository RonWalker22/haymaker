gdax = Exchange.find_by(name: 'GDAX')

Thread.new do
  sleep(10)
  EM.run {
    ws = Faye::WebSocket::Client.new('wss://ws-feed.gdax.com')

    pairs = []
    tickers = gdax.tickers
    # binding.pry
    tickers.each {|t| pairs << t.natural_pair}
    request = { "type": "subscribe",  "channels": [{ "name": "ticker",
    "product_ids": pairs }]}

      ws.on :open do |event|
        p [:open]
        ws.send(request.to_json)
      end

      ws.on :message do |event|
        # p [:message, event.data]
        message = JSON.parse event.data
        @new_price = message["price"].to_f.round(8) if message["price"]
        if message["type"] == 'ticker' && @old_price != @new_price
          @old_price = @new_price
          ticker = tickers.find_by natural_pair: message["product_id"]
          # binding.pry
          ticker.price = @new_price
          ticker.save
        end
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
  }
  ActiveRecord::Base.connection.close
end


binance = Exchange.find_by(name: 'Binance')

Thread.new do
  sleep(10)
  EM.run {
    # binance will disconnect after 24 hours.
    # Thanks for the pointer! In return, I offer this tip... do a WebSocket ping
    # every 30 seconds, with a timeout of 10 seconds. This will keep your WebSocket
    # from mysteriously going silent without disconnecting. But, even with this
    # the Binance WebSockets are not really robust, so you should code
    # for resiliency - detect failures and auto re-connect.

    pairs = []
    tickers = binance.tickers
    tickers.each {|t| pairs << "#{t.natural_pair.downcase}@trade"}
    pairs = pairs.join("/")
    # binding.pry
    ws = Faye::WebSocket::Client.new("wss://stream.binance.com:9443/ws/#{pairs}")
      ws.on :open do |event|
        p [:open]
      end

      ws.on :message do |event|
        # p [:message, event.data]
        message = JSON.parse event.data
        puts message["s"]
        ticker = tickers.find_by natural_pair: message["s"]
        ticker.price = message["p"]
        ticker.save
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
  }
  ActiveRecord::Base.connection.close
end


gemini = Exchange.find_by(name: 'Gemini')
gemini.tickers.each_with_index do |ticker, i|

  pair = ticker.natural_pair
  Thread.new do
  sleep(10) if i == 0
    EM.run {
    ws = Faye::WebSocket::Client.new("wss://api.gemini.com/v1/marketdata/#{pair}")

      ws.on :open do |event|
        p [:open]
      end

      ws.on :message do |event|
        message = JSON.parse event.data
        new_price = message["events"][0]["price"].to_f.round(8)
        if message["events"][0]["type"] == 'trade'
          ticker.price = new_price
          ticker.save
        end
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
    }
    ActiveRecord::Base.connection.close
  end
end
