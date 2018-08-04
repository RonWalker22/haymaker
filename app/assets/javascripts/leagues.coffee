tryLeverage = ->
  punches                = document.querySelectorAll ".fist"
  leverage_size          = document.querySelector    ".leverage-size"
  confirmation_modal     = document.querySelector    ".confirmation-modal"
  confirmation_meessage  = document.querySelector    ".confirmation-message"
  confirmation_action    = document.querySelector    ".confirmation-action"
  modal_background       = document.querySelector    ".modal-background"
  modal_close_btn        = document.querySelector    ".modal-close"
  cancel_fight_btn       = document.querySelector    ".cancel-fight"
  modal                  = document.querySelector    ".modal"
  activate               = document.querySelector    ".activate"
  reset                  = document.querySelector    ".reset"
  deleverage_btn         = document.querySelector    ".deleverage-btn"

  for punch in punches
    punch.addEventListener 'click', ->
      confirmation_action.dataset.method = "post"
      confirmation_action.href = "/leagues/1/swing/#{this.dataset.userid}"
      confirmation_meessage.innerText = "Are you sure you to engage in a fistfight with #{this.dataset.username}?"
      confirmation_modal.classList.add "is-active"

  modal_background.addEventListener 'click', ->
    modal.classList.remove "is-active"

  modal_close_btn.addEventListener 'click', ->
    modal.classList.remove "is-active"

  cancel_fight_btn.addEventListener 'click', ->
    modal.classList.remove "is-active"

  modal_background.addEventListener 'click', ->
    modal.classList.remove "is-active"

  if reset
    reset.addEventListener 'click', ->
      confirmation_action.dataset.method = "post"
      confirmation_meessage.innerText = "Are you sure you want to reset your practice league funds?"
      confirmation_action.href = "/leagues/1/reset_funds"
      confirmation_modal.classList.add "is-active"

  if activate
    activate.addEventListener 'click', ->
      size = +leverage_size.options[leverage_size.selectedIndex].value
      confirmation_action.dataset.method = "post"
      confirmation_meessage.innerText = "Are you sure you want to active #{size}x leverage?"
      confirmation_action.href = "/leagues/1/bet/#{size}"
      confirmation_modal.classList.add "is-active"
  else
    deleverage_btn.addEventListener 'click', ->
      confirmation_action.dataset.method = "post"
      confirmation_meessage.innerText = "Are you sure you want to deleverage your account?"
      confirmation_action.href = "/leagues/1/deleverage"
      confirmation_modal.classList.add "is-active"

tryPassword = ->
  community_select = document.querySelector('#community_select')
  password_input = document.querySelector('#league_password')

  community_select.addEventListener 'change', ->
    if community_select.value == 'Public'
      console.log 'hi'
      password_input.setAttribute 'disabled', true
      password_input.removeAttribute "required"
    if community_select.value == 'Private'
      console.log 'hi'
      password_input.removeAttribute "disabled"
      password_input.setAttribute 'required', true

document.addEventListener 'turbolinks:load', ->
  body = document.querySelector("body")
  if body.className == "leagues_show"
    tryLeverage()

  else if body.className == "leagues_new"
    tryPassword()
