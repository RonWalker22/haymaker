# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

tryWebsocket  = ->
  try
    Math.roundTo = (number, precision) ->
      Math.round(number * 10**precision) / 10**precision
    puts = (string) ->
      console.log string
    already_ran = false

    exchange = document.querySelector("#exchange")
    trading_pair = document.querySelector("#trading_pair").innerHTML
    cp1 = 
      document.querySelector("#coin_1_balance_label").innerHTML.toLowerCase()
    cp0 = 
      document.querySelector("#coin_0_balance_label").innerHTML.toLowerCase()

    up_arrow = document.querySelector(".up_arrow")
    down_arrow = document.querySelector(".down_arrow")
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
    
    pre_cap_25_btn = document.querySelector('#capital_percentage_25_')
    pre_cap_50_btn = document.querySelector('#capital_percentage_50_')
    pre_cap_75_btn = document.querySelector('#capital_percentage_75_')
    pre_cap_100_btn = document.querySelector('#capital_percentage_100_')
    cap_label_25 = document.querySelector('#cap_label_25')
    cap_label_50 = document.querySelector('#cap_label_50')
    cap_label_75 = document.querySelector('#cap_label_75')
    cap_label_100 = document.querySelector('#cap_label_100')

    ao_0 = [after_order_sign_0, after_order_value_0, after_order_total_0,
            ao_equal_sign_0, ]
    ao_1 = [after_order_sign_1, after_order_value_1, after_order_total_1,
            ao_equal_sign_1, ]

    allo = (target, percent, order_type, label)->
      if order_type == 'buy'
        target.addEventListener 'mouseover', ->
          label.style.background = "#ACB6E5"          
        target.addEventListener 'mouseout', ->
          label.style.background = "transparent"
      else 
        target.addEventListener 'mouseover', ->
          label.style.background = "#cf8bf3"
        target.addEventListener 'mouseout', ->
          label.style.background = "transparent"
      target.addEventListener 'click', ->
        if order_type == 'buy'
          all_coin = +balance_pair_values_0.textContent / +coin_price.innerHTML
          coin_quantity.value = Math.roundTo all_coin * percent, 8
          after_order_execute()
        else
          all_coin = +balance_pair_values_1.textContent
          coin_quantity.value = Math.roundTo all_coin * percent, 8
          after_order_execute()
    

    activate_allocation_listeners =  (order_type) ->
      allo pre_cap_25_btn, 0.25, order_type, cap_label_25
      allo pre_cap_50_btn, 0.5, order_type, cap_label_50
      allo pre_cap_75_btn, 0.75, order_type, cap_label_75
      allo pre_cap_100_btn, 1, order_type, cap_label_100

    after_order_execute = ->
      if Number(coin_quantity.value) > 0
        elm.style.visibility = 'visible' for elm in ao_0
        elm.style.visibility = 'visible' for elm in ao_1
        after_order_value_0.innerHTML = Number coin_quantity.value * 
          Number dynamic_price.value
        after_order_value_1.innerHTML = coin_quantity.value
        if "#{order_btn.getAttribute 'value'}" == "Place Buy Order"
          after_order_total_0.innerHTML = 
            Number(balance_pair_values_0.innerHTML) - 
              Number(after_order_value_0.innerHTML)
          after_order_total_1.innerHTML = 
            Number(balance_pair_values_1.innerHTML) + 
              Number(after_order_value_1.innerHTML)
        else if "#{order_btn.getAttribute 'value'}" == "Place Sell Order"
          after_order_total_0.innerHTML = 
            Number(balance_pair_values_0.innerHTML) + 
              Number(after_order_value_0.innerHTML)
          after_order_total_1.innerHTML = 
            Number(balance_pair_values_1.innerHTML) - 
              Number(after_order_value_1.innerHTML)
       else if Number(coin_quantity.value) <= 0
        elm.style.visibility = 'hidden' for elm in ao_0
        elm.style.visibility = 'hidden' for elm in ao_1

    after_order_fun = ->
      try
        coin_quantity.addEventListener 'input', ->
            after_order_execute()
      catch nil
        puts 'after_order_fun failed!'
        after_order_fun

    buy_btn.addEventListener 'click', ->
      sell_btn.style.cssText = "background: transparent; border-style: outset;"
      buy_btn.style.cssText = "background: #ACB6E5; border-style: inset;"
      order_btn.style.background = "#ACB6E5"
      order_btn.setAttribute "value", "Place Buy Order"
      after_order_sign_0.innerHTML = "-"
      after_order_sign_1.innerHTML = "+"
      elm.style.color = "#ACB6E5" for elm in ao_0
      elm.style.color = "#ACB6E5" for elm in ao_1
      after_order_total_0.innerHTML = 
        Number(balance_pair_values_0.innerHTML) - 
          Number(after_order_value_0.innerHTML)
      after_order_total_1.innerHTML = 
        Number(balance_pair_values_1.innerHTML) + 
          Number(after_order_value_1.innerHTML)
      activate_allocation_listeners('buy')

    
    sell_btn.addEventListener 'click', ->
      sell_btn.style.cssText = "background: #cf8bf3; border-style: inset;"
      buy_btn.style.cssText = "background: transparent; border-style: outset;"
      order_btn.style.background = "#cf8bf3"
      order_btn.setAttribute "value", "Place Sell Order"
      after_order_sign_0.innerHTML = "+"
      after_order_sign_1.innerHTML = "-"
      elm.style.color = "#cf8bf3" for elm in ao_0
      elm.style.color = "#cf8bf3" for elm in ao_1
      after_order_total_0.innerHTML = 
        Number(balance_pair_values_0.innerHTML) + 
          Number(after_order_value_0.innerHTML)
      after_order_total_1.innerHTML = 
        Number(balance_pair_values_1.innerHTML) -
          Number(after_order_value_1.innerHTML)
      activate_allocation_listeners('sell')

    dynamic_price = document.querySelector(".dynamic_price")
    if exchange
      past_price = 0

      switch exchange.innerHTML.toLowerCase()
        when 'gdax'
          socket = new WebSocket 'wss://ws-feed.gdax.com'
          request = { "type": "subscribe",  "channels": [{ "name": "ticker",
          "product_ids": [trading_pair] }]}
          price_ws_target = "price"
          puts '<--------->GDAX WebSocket!<--------->'
        when 'binance' 
          socket = 
            new WebSocket "wss://stream.binance.com:9443/ws/#{cp1}#{cp0}@trade"
          price_ws_target = "p"
          puts '<--------->BINANCE WebSocket!<--------->'

      socket.onerror = (error) ->
        puts "WebSocket Error: ${error}"

      socket.onclose = (event) -> 
        puts 'Disconnected from WebSocket.'

      socket.onopen = (event) -> 
        puts 'WebSocket is connected!'
        socket.send JSON.stringify request if request 


      socket.onmessage = (event) -> 
        coin_price = document.querySelector("#coin_price")
        message = JSON.parse(event.data)
        after_order_fun()
        price = parseFloat(message[price_ws_target]).toFixed(2)
        callback = ->
          down_arrow.style.visibility = 'hidden'
          up_arrow.style.visibility = 'hidden'
        if !isNaN(price)
          try
            dynamic_price.setAttribute "value", price
            coin_price.innerHTML = "#{price}"
            activate_allocation_listeners('buy') unless already_ran
            already_ran = true
            puts price
            if price > past_price
              past_price = price
              down_arrow.style.visibility = 'hidden'
              up_arrow.style.cssText = 
                "visibility: visible; border-color:#5fff33;"
              setTimeout callback, 1000
            else if price < past_price
              past_price = price
              up_arrow.style.visibility = 'hidden'
              down_arrow.style.cssText = "visibility: visible;
              border-color:red;"
              setTimeout callback, 1000
          catch error
            puts 'Waiting to reconnect'
            socket.close()
            callback = tryWebsocket
            setTimeout callback, 3000
    else
      puts 'Waiting to connect'
      callback = tryWebsocket
      setTimeout callback, 3000
  catch error
    puts 'waiting to connect through click'
    callback = tryWebsocket
    setTimeout callback, 3000



window.addEventListener 'load', ->
  tryWebsocket()


