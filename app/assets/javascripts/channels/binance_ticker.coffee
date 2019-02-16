App.binance_ticker = App.cable.subscriptions.create "BinanceTickerChannel",
  connected: ->
  disconnected: ->

  received: (data) ->
    coin_price   = document.querySelector("#coin_price")
    trading_pair = document.querySelector("#trading_pair")
    exchange     = document.querySelector("#exchange")

    if trading_pair
      if data.pair == trading_pair.innerHTML && data.exchange == exchange.dataset.exchange
        coin_price.innerHTML = data.price
