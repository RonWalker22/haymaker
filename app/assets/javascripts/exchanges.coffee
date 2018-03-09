# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

tryWebsocket  = ->
  dynamic_price = document.querySelector(".dynamic_price")
  buy_btn = document.querySelector('#buy_btn')
  sell_btn = document.querySelector('#sell_btn')
  coin_price = document.querySelector('#coin_price')
  order_btn = document.querySelector('#order_btn')
  coin_quantity = document.querySelector('#coin_quantity')
  coin_2_quantity =  coin_price.textContent
  after_order_sign = document.querySelector('.after_order_sign')
  after_order_sign_0 = document.querySelector('#after_order_sign_0')
  after_order_sign_1 = document.querySelector('#after_order_sign_1')
  after_order_value = document.querySelector('.after_order_value')
  after_order_value_0 = document.querySelector('#after_order_value_0')
  after_order_value_1 = document.querySelector('#after_order_value_1')
  after_order_total = document.querySelector('.after_order_total')
  after_order_total_0 = document.querySelector('#after_order_total_0')
  after_order_total_1 = document.querySelector('#after_order_total_1')
  balance_pair_values_0 = document.querySelector('#balance_pair_values_0')
  balance_pair_values_1 = document.querySelector('#balance_pair_values_1')
  ao_equal_sign = document.querySelector('.ao_equal_sign')
  ao_equal_sign_0 = document.querySelector('#ao_equal_sign_0')
  ao_equal_sign_1 = document.querySelector('#ao_equal_sign_1')

  after_oder_fun = ->
    coin_quantity.addEventListener 'input', ->
      after_order_value.style.display = 'inline'
      after_order_sign.style.display = 'inline'
      after_order_total.style.display = 'inline'
      after_order_value_0.innerHTML = Number coin_quantity.value * 
        Number dynamic_price.value
      after_order_value_1.innerHTML = coin_quantity.value

      console.log coin_quantity.valuee
      console.log dynamic_price.value


  buy_btn.addEventListener 'click', ->
    sell_btn.style.cssText = "background: transparent; border-style: outset;"
    buy_btn.style.cssText = "background: #ccff66; border-style: inset;"
    order_btn.style.background = "#ccff66"
    order_btn.setAttribute "value", "Place Buy Order"
    after_order_sign_0.innerHTML = "+"
    after_order_sign_1.innerHTML = "-"
    after_order_total.style.cssText = "color: #ccff66;"
    after_order_value.style.cssText = "color: #ccff66;"
    after_order_sign.style.cssText = "color: #ccff66;"
    ao_equal_sign.style.cssText = "color: #ccff66;"

  sell_btn.addEventListener 'click', ->
    sell_btn.style.cssText = "background: #004d00; border-style: inset;"
    buy_btn.style.cssText = "background: transparent; border-style: outset;"
    order_btn.style.background = "#004d00"
    order_btn.setAttribute "value", "Place Sell Order"
    after_order_sign_0.innerHTML = "-"
    after_order_sign_1.innerHTML = "+"
    after_order_total.style.cssText = "color: rgb(0, 77, 0);"
    after_order_value.style.cssText = "color: rgb(0, 77, 0);"
    after_order_sign.style.cssText = "color: rgb(0, 77, 0);"
    ao_equal_sign.style.cssText = "color: rgb(0, 77, 0);"



  dynamic_price = document.querySelector(".dynamic_price")
  exchange = document.querySelector("#exchange")
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
      after_oder_fun()
      price = parseFloat(message["price"]).toFixed(2)
      callback = ->
        coin_price.style.color = "#eafaea"
      if !isNaN(price)
        try
          dynamic_price.setAttribute "value", price
          coin_price.innerHTML = "#{price}"
          if price > past_price
            past_price = price
            coin_price.style.color = "#5fff33"
            setTimeout callback, 300
          else if price < past_price
            past_price = price
            coin_price.style.color = "red"
            setTimeout callback, 300
        catch error
          console.log 'Waiting to reconnect'
  else
    console.log 'Waiting to connect'
    callback = tryWebsocket
    setTimeout callback, 3000

window.addEventListener 'load', tryWebsocket


