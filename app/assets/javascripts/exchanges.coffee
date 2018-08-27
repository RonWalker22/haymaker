# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

tryWebsocket  = ->
  try
    Math.roundTo = (number, precision) ->
      Math.round(number * 10**precision) / 10**precision
    puts = (string) ->
      console.log string
    current_value = (element) ->
      document.querySelector("##{element.id}").value
    current_ihtml = (element) ->
      document.querySelector("##{element.id}").innerHTML

    price_target          = document.querySelector("#price_target")
    custom_order          = document.querySelector("#custom_order")
    direction             = document.querySelector("#direction")
    price_cap             = document.querySelector("#price_cap")
    price_cap_container   = document.querySelector("#price_cap_container")
    price_cap_label       = document.querySelector("#price_cap_label")
    price_cap_max         = document.querySelector("#price_cap_max")
    past_orders_title     = document.querySelector("#past_orders_title")
    filled_orders_btn     = document.querySelector("#filled-orders-btn")
    open_orders_btn       = document.querySelector("#open-orders-btn")
    delete_btns           = document.querySelectorAll(".delete")
    price_climbs          = document.querySelector("#price_climbs")
    price_falls           = document.querySelector("#price_falls")

    trading_pair = document.querySelector("#trading_pair").innerHTML
    cp1 =
      document.querySelector("#coin_1_balance_label").innerHTML.toLowerCase()
    cp0 =
      document.querySelector("#coin_0_balance_label").innerHTML.toLowerCase()

    coin_price      = document.querySelector("#coin_price")
    buy_btn         = document.querySelector('#buy_btn')
    sell_btn        = document.querySelector('#sell_btn')
    order_btn       = document.querySelector('#order_btn')
    coin_quantity   = document.querySelector('#order_quantity')

    balance_pair_values_0 = document.querySelector('#balance_pair_values_0')
    balance_pair_values_1 = document.querySelector('#balance_pair_values_1')

    after_order_sign    = document.querySelector('.after_order_sign')
    after_order_sign_0  = document.querySelector('#after_order_sign_0')
    after_order_sign_1  = document.querySelector('#after_order_sign_1')
    after_order_value   = document.querySelector('.after_order_value')
    after_order_value_0 = document.querySelector('#after_order_value_0')
    after_order_value_1 = document.querySelector('#after_order_value_1')
    after_order_total   = document.querySelector('.after_order_total')
    after_order_total_0 = document.querySelector('#after_order_total_0')
    after_order_total_1 = document.querySelector('#after_order_total_1')
    ao_equal_sign       = document.querySelector('.ao_equal_sign')
    ao_equal_sign_0     = document.querySelector('#ao_equal_sign_0')
    ao_equal_sign_1     = document.querySelector('#ao_equal_sign_1')

    cap_25  = document.querySelector('#cap_25')
    cap_50  = document.querySelector('#cap_50')
    cap_75  = document.querySelector('#cap_75')
    cap_100 = document.querySelector('#cap_100')

    custom_order.addEventListener 'click', ->
      price_target.value = ''
      price_cap.value = ''
      price_cap_container.style.display = 'none'
      if current_value(order_btn) == 'Place Buy Order'
        direction.selectedIndex = 0
        price_cap_label.innerHTML = 'Floor:'
      else
        direction.selectedIndex = 1
        price_cap_label.innerHTML = 'Ceiling:'

    for btn in delete_btns
      btn.addEventListener 'mouseover', ->
        @default_color = this.parentNode.parentNode.parentNode.style.background
        this.parentNode.parentNode.parentNode.style.background = '#6f2222'
      btn.addEventListener 'mouseout', ->
        this.parentNode.parentNode.parentNode.style.background = @default_color

    price_cap_max.addEventListener 'click', ->
      available_quantity = Math.roundTo +balance_pair_values_0.textContent, 8
      order_quantity = Math.roundTo +document.querySelector('#order_quantity').value, 8
      price_max = available_quantity / order_quantity
      price_cap.value = Math.roundTo price_max, 8

    filled_orders_btn.addEventListener 'click', ->
      if past_orders_title.innerHTML != 'Filled Orders'
        past_orders_title.innerHTML = 'Filled Orders'

    open_orders_btn.addEventListener 'click', ->
      if past_orders_title.innerHTML != 'Open Orders'
        past_orders_title.innerHTML = 'Open Orders'

    direction.addEventListener 'change', ->
      if current_value(order_btn) == 'Place Buy Order' && current_value(direction) == 'price_climbs'
        price_cap_container.style.display = 'block'
      else if current_value(order_btn) == 'Place Sell Order' && current_value(direction) == 'price_falls'
        price_cap_container.style.display = 'block'
      else
        price_cap_container.style.display = 'none'
      if current_value(direction) == 'price_falls'
        price_cap_label.innerHTML = 'Floor:'
      else
        price_cap_label.innerHTML = 'Ceiling:'

    ao_0 = [after_order_sign_0, after_order_value_0, after_order_total_0,
            ao_equal_sign_0, ]
    ao_1 = [after_order_sign_1, after_order_value_1, after_order_total_1,
            ao_equal_sign_1, ]

    allo = (target_element, percent, order_type)->
      target_element.addEventListener 'click', ->
        if order_type == 'buy'
          if document.querySelector("#price_target").value == ""
            coin_price = document.querySelector('#coin_price')
            all_coin = Math.roundTo +balance_pair_values_0.textContent /
              +coin_price.innerHTML, 8
            puts all_coin
          else
            coin_price = document.querySelector("#price_target")
            all_coin = Math.roundTo +balance_pair_values_0.textContent /
              +coin_price.value, 8
          coin_quantity.value = Math.roundTo all_coin * percent, 8
          after_order_execute()
        else
          all_coin = Math.roundTo +balance_pair_values_1.textContent, 8
          coin_quantity.value = Math.roundTo all_coin * percent, 8
          after_order_execute()


    activate_allocation_listeners =  (order_type) ->
      allo cap_25, 0.25, order_type
      allo cap_50, 0.5, order_type
      allo cap_75, 0.75, order_type
      allo cap_100, 1, order_type

    activate_allocation_listeners('buy')

    after_order_execute = ->
      if +coin_quantity.value > 0
        elm.style.visibility = 'visible' for elm in ao_0
        elm.style.visibility = 'visible' for elm in ao_1
        if document.querySelector("#price_target").value == ""
          coin_price = document.querySelector('#coin_price')
          after_order_value_0.innerHTML =
            Math.roundTo +coin_quantity.value * +coin_price.innerHTML, 8
        else
          coin_price = document.querySelector('#price_target')
          after_order_value_0.innerHTML =
            Math.roundTo +coin_quantity.value * +coin_price.value, 8
        after_order_value_1.innerHTML = Math.roundTo coin_quantity.value, 8
        if "#{order_btn.getAttribute 'value'}" == "Place Buy Order"
          after_order_total_0.innerHTML =
            Math.roundTo +balance_pair_values_0.innerHTML -
              +after_order_value_0.innerHTML, 8
          after_order_total_1.innerHTML =
            Math.roundTo +balance_pair_values_1.innerHTML +
              +after_order_value_1.innerHTML, 8
        else if "#{order_btn.getAttribute 'value'}" == "Place Sell Order"
          after_order_total_0.innerHTML =
            Math.roundTo +balance_pair_values_0.innerHTML +
              +after_order_value_0.innerHTML, 8
          after_order_total_1.innerHTML =
            Math.roundTo +balance_pair_values_1.innerHTML -
              +after_order_value_1.innerHTML, 8
       else if +coin_quantity.value <= 0
        elm.style.visibility = 'hidden' for elm in ao_0
        elm.style.visibility = 'hidden' for elm in ao_1

    coin_quantity.addEventListener 'input', ->
      after_order_execute()
    price_target.addEventListener 'input', ->
      after_order_execute()


    buy_btn.addEventListener 'click', ->
      sell_btn.style.background = "#4B79A1"
      buy_btn.style.background = "#149a19"
      order_btn.style.background = "#149a19"
      order_btn.setAttribute "value", "Place Buy Order"
      after_order_sign_0.innerHTML = "-"
      after_order_sign_1.innerHTML = "+"
      after_order_total_0.innerHTML =
        Math.roundTo +balance_pair_values_0.innerHTML -
          +after_order_value_0.innerHTML, 8
      after_order_total_1.innerHTML =
        Math.roundTo +balance_pair_values_1.innerHTML +
          +after_order_value_1.innerHTML, 8
      activate_allocation_listeners('buy')
      price_cap_container.style.display = 'none'
      price_climbs.innerHTML = "Price climbs within"
      price_falls.innerHTML  = "Price falls to"
      direction.selectedIndex = 0
      price_cap_label.innerHTML = 'Floor:'
      price_cap.value = ''
      price_target.value = ''
      price_cap_max.style.display = 'inline-flex'
      price_falls.removeAttribute 'disabled'
      price_climbs.setAttribute 'disabled', 'true'


    sell_btn.addEventListener 'click', ->
      sell_btn.style.background = "#de6161"
      buy_btn.style.background = "#4B79A1"
      order_btn.style.background = "#de6161"
      order_btn.setAttribute "value", "Place Sell Order"
      after_order_sign_0.innerHTML = "+"
      after_order_sign_1.innerHTML = "-"
      after_order_total_0.innerHTML =
        Math.roundTo +balance_pair_values_0.innerHTML +
          +after_order_value_0.innerHTML, 8
      after_order_total_1.innerHTML =
        Math.roundTo +balance_pair_values_1.innerHTML -
          +after_order_value_1.innerHTML, 8
      activate_allocation_listeners('sell')
      price_cap_container.style.display = 'none'
      price_climbs.innerHTML = "Price climbs to"
      price_falls.innerHTML  = "Price falls within"
      direction.selectedIndex = 0
      direction.selectedIndex = 1
      price_cap_label.innerHTML = 'Ceiling:'
      price_falls.setAttribute 'disabled', 'true'
      price_climbs.removeAttribute 'disabled'
      price_cap.value = ''
      price_target.value = ''
      price_cap_max.style.display = 'none'

  catch error
    puts 'waiting to connect through click'
    callback = tryWebsocket
    setTimeout callback, 1000


document.addEventListener 'turbolinks:load', ->
  body = document.querySelector("body")
  if body.className == "exchanges_show"
    tryWebsocket()
