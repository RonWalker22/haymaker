document.addEventListener 'turbolinks:load', ->
  trading_pair = document.querySelector("#trading_pair")
  if trading_pair
    if App.binance_ticker
      App.binance_ticker.unsubscribe()
    App.binance_ticker = App.cable.subscriptions.create { channel: "BinanceTickerChannel", room: trading_pair.innerHTML },
      connected: ->
        console.log("Connected to BinanceTickerChannel")
      disconnected: ->
      received: (data) ->
        console.log(data.price)
        coin_price.innerHTML = data.price
