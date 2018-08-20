App.binance_ticker = App.cable.subscriptions.create "BinanceTickerChannel",
  connected: ->
    console.log 'Connected to B ticker'
  disconnected: ->
    console.log 'Disconnected'

  received: (data) ->
    coin_price   = document.querySelector("#coin_price")
    trading_pair = document.querySelector("#trading_pair").innerHTML
    exchange     = document.querySelector("#exchange")

    if data.pair == trading_pair && data.exchange == exchange.dataset.exchange
      coin_price.innerHTML = data.price
