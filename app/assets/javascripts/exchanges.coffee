# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

tryWebsocket  = ->
  dynamic_price = document.querySelector(".dynamic_price")
  console.log dynamic_price
  title = document.querySelector("#title")
  console.log title
  if title
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
      message = JSON.parse(event.data)
      price = parseFloat(message["price"]).toFixed(2)
      waiting_counter = 0
      if !isNaN(price)
        try
          dynamic_price.setAttribute "value", price
          document.querySelector("#gdax_btc_price").innerHTML = 
            "Bitcoin Price $#{price}"
          console.log price
        catch error
          console.log 'Waiting to reconnect'
  else
    console.log 'Waiting to connect'
    callback = tryWebsocket
    setTimeout callback, 3000

window.addEventListener 'load', tryWebsocket





