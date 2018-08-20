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
    price_limit           = document.querySelector("#price_limit")
    price_limit_container = document.querySelector("#price_limit_container")
    price_limit_label     = document.querySelector("#price_limit_label")
    price_limit_min       = document.querySelector("#price_limit_min")
    price_limit_max       = document.querySelector("#price_limit_max")
    past_orders_title     = document.querySelector("#past_orders_title")
    filled_orders_btn     = document.querySelector("#filled-orders-btn")
    open_orders_btn       = document.querySelector("#open-orders-btn")
    delete_btns           = document.querySelectorAll(".delete")
    price_climbs          = document.querySelectorAll(".price_climbs")
    price_falls           = document.querySelectorAll(".price_falls")

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
      price_limit.value = ''
      price_limit_container.style.display = 'none'
      if current_value(order_btn) == 'Place Buy Order'
        direction.value    = 'price_falls'
        price_limit_label.innerHTML = 'Floor:'
      else
        direction.value    = 'price_climbs'
        price_limit_label.innerHTML = 'Ceiling:'

    for btn in delete_btns
      btn.addEventListener 'mouseover', ->
        @default_color = this.parentNode.parentNode.parentNode.style.background
        this.parentNode.parentNode.parentNode.style.background = 'black'
      btn.addEventListener 'mouseout', ->
        this.parentNode.parentNode.parentNode.style.background = @default_color

    price_limit_max.addEventListener 'click', ->
      if document.querySelector('#order_btn').value == 'Place Buy Order'
        price_max = Math.roundTo +balance_pair_values_0.textContent, 8 /
          Math.roundTo +document.querySelector('#order_quantity').value, 8
        price_limit.value = Math.roundTo price_max, 8
      else
        price_limit.value = 0

    filled_orders_btn.addEventListener 'click', ->
      if past_orders_title.innerHTML != 'Filled Orders'
        past_orders_title.innerHTML = 'Filled Orders'

    open_orders_btn.addEventListener 'click', ->
      if past_orders_title.innerHTML != 'Open Orders'
        past_orders_title.innerHTML = 'Open Orders'

    price_limit_min.addEventListener 'click', ->
      price_limit.value = document.querySelector('#price_target').value

    direction.addEventListener 'change', ->
      if current_value(order_btn) == 'Place Buy Order' && current_value(direction) == 'price_climbs'
        price_limit_container.style.display = 'block'
      else if current_value(order_btn) == 'Place Sell Order' && current_value(direction) == 'price_falls'
        price_limit_container.style.display = 'block'
      else
        price_limit_container.style.display = 'none'
      if current_value(direction) == 'price_falls'
        price_limit_label.innerHTML = 'Floor:'
      else
        price_limit_label.innerHTML = 'Ceiling:'

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
      price_limit_container.style.display = 'none'
      direction.innerHTML =
        "<option value='" + "price_falls" + "'>" +"Price fall to" +
          "</option> <option value='" + "price_climbs" + "'>" +
            "Price climbs within" + "</option>"
      direction.value = 'price_falls'
      price_limit_label.innerHTML = 'Floor:'
      price_limit.value = ''
      price_target.value = ''


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
      price_limit_container.style.display = 'none'
      direction.value = 'price_climbs'
      direction.innerHTML =
        "<option value='" + "price_falls" + "'>" +"Price fall within" +
          "</option> <option value='" + "price_climbs" + "'>" +
            "Price climbs to" + "</option>"
      direction.value = 'price_climbs'
      price_limit_label.innerHTML = 'Ceiling:'
      price_limit.value = ''
      price_target.value = ''

  catch error
    puts 'waiting to connect through click'
    callback = tryWebsocket
    setTimeout callback, 1000


document.addEventListener 'turbolinks:load', ->
  body = document.querySelector("body")
  if body.className == "exchanges_show"
    tryWebsocket()
