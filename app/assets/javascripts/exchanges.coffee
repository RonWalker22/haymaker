# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


tryWebsocket  = ->
  try 
    dynamic_price = document.querySelector(".dynamic_price")
    buy_btn = document.querySelector('#buy_btn')
    sell_btn = document.querySelector('#sell_btn')
    coin_price = document.querySelector('#coin_price')
    order_btn = document.querySelector('#order_btn')
    coin_quantity = document.querySelector('#order_quantity')
    coin_2_quantity =  coin_price.textContent

    balance_pair_values_0 = document.querySelector('#balance_pair_values_0')
    balance_pair_values_1 = document.querySelector('#balance_pair_values_1')

    after_order_sign = document.querySelector('.after_order_sign')
    after_order_sign_0 = document.querySelector('#after_order_sign_0')
    after_order_sign_1 = document.querySelector('#after_order_sign_1')
    after_order_value = document.querySelector('.after_order_value')
    after_order_value_0 = document.querySelector('#after_order_value_0')
    after_order_value_1 = document.querySelector('#after_order_value_1')
    after_order_total = document.querySelector('.after_order_total')
    after_order_total_0 = document.querySelector('#after_order_total_0')
    after_order_total_1 = document.querySelector('#after_order_total_1')
    ao_equal_sign = document.querySelector('.ao_equal_sign')
    ao_equal_sign_0 = document.querySelector('#ao_equal_sign_0')
    ao_equal_sign_1 = document.querySelector('#ao_equal_sign_1')
    
    ao_0 = [after_order_sign_0, after_order_value_0, after_order_total_0,
            ao_equal_sign_0, ]
    ao_1 = [after_order_sign_1, after_order_value_1, after_order_total_1,
            ao_equal_sign_1, ]

    after_order_fun_reset = ->
      coin_quantity.addEventListener 'input', ->
        if Number(coin_quantity.value) <= 0
          elm.style.visibility = 'hidden' for elm in ao_0
          elm.style.visibility = 'hidden' for elm in ao_1



    after_order_fun = ->
      coin_quantity.addEventListener 'input', ->
        after_order_fun_reset()
        if Number(coin_quantity.value) > 0
          elm.style.visibility = 'visible' for elm in ao_0
          elm.style.visibility = 'visible' for elm in ao_1
          after_order_value_0.innerHTML = Number coin_quantity.value * 
            Number dynamic_price.value
          after_order_value_1.innerHTML = coin_quantity.value
          console.log "amount input hit"
          console.log order_btn.getAttribute "value"
          if "#{order_btn.getAttribute 'value'}" == "Place Buy Order"
            after_order_total_0.innerHTML = Number(balance_pair_values_0.innerHTML) - Number(after_order_value_0.innerHTML)
            after_order_total_1.innerHTML = Number(balance_pair_values_1.innerHTML) + Number(after_order_value_1.innerHTML)
          else if "#{order_btn.getAttribute 'value'}" == "Place Sell Order"
            after_order_total_0.innerHTML = Number(balance_pair_values_0.innerHTML) + Number(after_order_value_0.innerHTML)
            after_order_total_1.innerHTML = Number(balance_pair_values_1.innerHTML) - Number(after_order_value_1.innerHTML)

    buy_btn.addEventListener 'click', ->
      sell_btn.style.cssText = "background: transparent; border-style: outset;"
      buy_btn.style.cssText = "background: #ACB6E5; border-style: inset;"
      order_btn.style.background = "#ACB6E5"
      order_btn.setAttribute "value", "Place Buy Order"
      after_order_sign_0.innerHTML = "-"
      after_order_sign_1.innerHTML = "+"
      elm.style.color = "#ACB6E5" for elm in ao_0
      elm.style.color = "#ACB6E5" for elm in ao_1
      after_order_total_0.innerHTML = Number(balance_pair_values_0.innerHTML) -
        Number(after_order_value_0.innerHTML)
      after_order_total_1.innerHTML = Number(balance_pair_values_1.innerHTML) +
        Number(after_order_value_1.innerHTML)

    sell_btn.addEventListener 'click', ->
      sell_btn.style.cssText = "background: #cf8bf3; border-style: inset;"
      buy_btn.style.cssText = "background: transparent; border-style: outset;"
      order_btn.style.background = "#cf8bf3"
      order_btn.setAttribute "value", "Place Sell Order"
      after_order_sign_0.innerHTML = "+"
      after_order_sign_1.innerHTML = "-"
      elm.style.color = "#cf8bf3" for elm in ao_0
      elm.style.color = "#cf8bf3" for elm in ao_1
      after_order_total_0.innerHTML = Number(balance_pair_values_0.innerHTML) +
        Number(after_order_value_0.innerHTML)
      after_order_total_1.innerHTML = Number(balance_pair_values_1.innerHTML) -
        Number(after_order_value_1.innerHTML)

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
        after_order_fun()
        price = parseFloat(message["price"]).toFixed(2)
        callback = ->
          coin_price.style.color = "white"
        if !isNaN(price)
          try
            dynamic_price.setAttribute "value", price
            coin_price.innerHTML = "#{price}"
            console.log price
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
  catch error
    console.log 'error or waiting to connect through click'
    callback = tryWebsocket
    setTimeout callback, 3000

window.addEventListener 'load', tryWebsocket


