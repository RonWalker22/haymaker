tryMargin = ->
  puts = (string) ->
    console.log string
  Math.roundTo = (number, precision) ->
    Math.round(number * 10**precision) / 10**precision

  puts 'margin connected!'

  liquidation_calculator = document.querySelector    ".liquidation-calculator"
  liquidation_modal      = document.querySelector    ".liquidation-modal"
  modal_background       = document.querySelector    ".modal-background"
  modal_close_btn        = document.querySelector    ".modal-close"
  modal                  = document.querySelector    ".modal"
  body                   = document.querySelector    "body"
  leverage_options       = document.querySelector    ".leverage_options"
  portfolio_value        = document.querySelector    ".portfolio_value"
  liquidation            = document.querySelector    ".liquidation"

  leverage_size =
    +leverage_options.options[leverage_options.selectedIndex].dataset.leverage
  liquidation_trigger =
    +leverage_options.options[leverage_options.selectedIndex].dataset.trigger

  liquidation.value   = Math.roundTo (portfolio_value.value -
    (liquidation_trigger * portfolio_value.value)), 8

  if body.className == "leagues_margin"
    liquidation_calculator.addEventListener 'click', ->
      liquidation_modal.classList.add "is-active"

  modal_background.addEventListener 'click', ->
    modal.classList.remove "is-active"

  modal_close_btn.addEventListener 'click', ->
    leverage_options.value = 1
    modal.classList.remove "is-active"

  modal_background.addEventListener 'click', ->
    leverage_options.value = 1
    modal.classList.remove "is-active"

  leverage_options.addEventListener 'change', ->
    leverage_size =
      +leverage_options.options[leverage_options.selectedIndex].dataset.leverage
    liquidation_trigger =
      +leverage_options.options[leverage_options.selectedIndex].dataset.trigger
    liquidation.value   = Math.roundTo portfolio_value.value -
      (liquidation_trigger * portfolio_value.value ), 8




document.addEventListener 'turbolinks:load', ->
  body = document.querySelector("body")
  if body.className == "leagues_margin" || "leagues_show"
    tryMargin()
