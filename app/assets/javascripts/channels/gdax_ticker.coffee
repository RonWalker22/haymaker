
App.gdax_ticker = App.cable.subscriptions.create {channel:"GdaxTickerChannel"},
  connected: ->
    # Called when the subscription is ready for use on the server
    console.log 'Connected'

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log 'Disconnected'

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    coin_price = document.querySelector("#coin_price")
    trading_pair = document.querySelector("#trading_pair").innerHTML
    exchange = document.querySelector("#exchange").innerHTML
    if data.pair == trading_pair && data.exchange == exchange.split(' ')[0]
      console.log "#{data.price}"
      coin_price.innerHTML = data.price
      console.log "#{exchange}"
      console.log data.exchange
