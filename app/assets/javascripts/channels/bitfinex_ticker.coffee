App.bitfinex_ticker = App.cable.subscriptions.create "BitfinexTickerChannel",
  connected: ->
    console.log 'Connected'

  disconnected: ->
    console.log 'Disconnected'

  received: (data) ->
    coin_price   = document.querySelector("#coin_price")
    trading_pair = document.querySelector("#trading_pair").innerHTML
    exchange     = document.querySelector("#exchange").innerHTML
    up_arrow     = document.querySelector(".fa-arrow-up")
    down_arrow   = document.querySelector(".fa-arrow-down")

    callback = ->
      down_arrow.style.visibility = 'hidden'
      up_arrow.style.visibility = 'hidden'

    if data.pair == trading_pair && data.exchange == exchange.split(' ')[0]
      console.log data.price
      coin_price.innerHTML = data.price
      if parseFloat data.price < parseFloat
        up_arrow.style.visibility = 'hidden'
        down_arrow.style.cssText  = "visibility: visible; color:red;"
        setTimeout callback, 1000
      else if parseFloat data.price > parseFloat
        down_arrow.style.visibility = 'hidden'
        up_arrow.style.cssText      = "visibility: visible; color:#5fff33;"
        setTimeout callback, 1000
