# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

tryWebsocket  = ->
  buy_btn = document.querySelector('#buy_btn')
  sell_btn = document.querySelector('#sell_btn')
  coin_price = document.querySelector('#coin_price')
  order_btn = document.querySelector('#order_btn')

  buy_btn.addEventListener 'click', ->
    sell_btn.style.cssText = "background: transparent; border-style: outset;"
    buy_btn.style.cssText = "background: #ccff66; border-style: inset;"
    order_btn.style.background = "#ccff66"
    order_btn.setAttribute "value", "Place Buy Order"

  sell_btn.addEventListener 'click', ->
    sell_btn.style.cssText = "background: #004d00; border-style: inset;"
    buy_btn.style.cssText = "background: transparent; border-style: outset;"
    order_btn.style.background = "#004d00"
    order_btn.setAttribute "value", "Place Sell Order"

  dynamic_price = document.querySelector(".dynamic_price")
  console.log dynamic_price
  exchange = document.querySelector("#exchange")
  console.log exchange
  if exchange
    past_price = 0
    socket = new WebSocket 'wss://ws-feed.gdax.com'
    socket.onerror = (error) ->
      console.log "WebSocket Error: ${error}"

    socket.onclose = (event) -> 
      console.log 'Disconnected from WebSocket.'

    socket.onopen = (event) -> 
      console.log 'WebSocket is connected!'
      request = { "type": "subscribe",  "channels": [{ "name": "ticker",
      "product_ids": ["BTC-USD"] }]}
      socket.send JSON.stringify request

    socket.onmessage = (event) -> 
      coin_price = document.querySelector("#coin_price")
      message = JSON.parse(event.data)
      price = parseFloat(message["price"]).toFixed(2)
      callback = ->
        coin_price.style.color = "#eafaea"
      if !isNaN(price)
        try
          dynamic_price.setAttribute "value", price
          coin_price.innerHTML = "$#{price}"
          if price > past_price
            past_price = price
            coin_price.style.color = "#5fff33"
            setTimeout callback, 300
          else if price < past_price
            past_price = price
            coin_price.style.color = "red"
            setTimeout callback, 300
          console.log price
        catch error
          console.log 'Waiting to reconnect'
  else
    console.log 'Waiting to connect'
    callback = tryWebsocket
    setTimeout callback, 3000

window.addEventListener 'load', tryWebsocket


