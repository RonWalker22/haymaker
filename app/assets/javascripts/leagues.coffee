tryModal = ->
  confirmation_modal     = document.querySelector    ".confirmation-modal"
  confirmation_meessage  = document.querySelector    ".confirmation-message"
  confirmation_action    = document.querySelector    ".confirmation-action"
  modal_background       = document.querySelector    ".modal-background"
  modal_close_btn        = document.querySelector    ".modal-close"
  cancel_modal_btn       = document.querySelector    ".cancel-modal"
  body                   = document.querySelector    "body"

  modal_background.addEventListener 'click', ->
    confirmation_modal.classList.remove "is-active"

  modal_close_btn.addEventListener 'click', ->
    confirmation_modal.classList.remove "is-active"

  cancel_modal_btn.addEventListener 'click', ->
    confirmation_modal.classList.remove "is-active"

  tryLeverage = ->
    punches                = document.querySelectorAll ".fist"
    leverage_size          = document.querySelector    ".leverage-size"
    activate_leverage      = document.querySelector    ".activate-leverage"
    activate_shield        = document.querySelector    ".activate-shield"
    activate_auto_shield   = document.querySelector    ".activate-auto-shield"
    reset                  = document.querySelector    ".reset"
    deleverage_btn         = document.querySelector    ".deleverage-btn"
    leave_btn              = document.querySelector    "#leave-btn"
    league_info            = document.querySelector    "#league-info"
    league_id              = league_info.dataset.leagueid
    user_id                = league_info.dataset.userid

    for punch in punches
      punch.addEventListener 'click', ->
        confirmation_action.dataset.method = "post"
        confirmation_action.href = "/leagues/#{league_id}/swing/#{this.dataset.userid}"
        confirmation_meessage.innerText = "Engage in a fistfight with #{this.dataset.username}?"
        confirmation_modal.classList.add "is-active"

    if reset
      reset.addEventListener 'click', ->
        confirmation_action.dataset.method = "post"
        confirmation_meessage.innerText = "Reset your practice league funds?"
        confirmation_action.href = "/leagues/1/reset"
        confirmation_modal.classList.add "is-active"

    if leave_btn
      leave_btn.addEventListener 'click', ->
        confirmation_action.dataset.method = "delete"
        confirmation_meessage.innerText = "Leave this league?"
        confirmation_action.href = "/leagues/#{league_id}/players/#{user_id}"
        confirmation_modal.classList.add "is-active"

    if activate_leverage
      activate_leverage.addEventListener 'click', ->
        size = +leverage_size.options[leverage_size.selectedIndex].value
        confirmation_action.dataset.method = "post"
        confirmation_meessage.innerText = "Active #{size}x leverage?"
        confirmation_action.href = "/leagues/#{league_id}/bet/#{size}"
        confirmation_modal.classList.add "is-active"
    else if deleverage_btn
      deleverage_btn.addEventListener 'click', ->
        confirmation_action.dataset.method = "post"
        confirmation_meessage.innerText = "Deleverage your account?"
        confirmation_action.href = "/leagues/#{league_id}/deleverage"
        confirmation_modal.classList.add "is-active"
    if activate_shield
      activate_shield.addEventListener 'click', ->
        confirmation_action.dataset.method = "post"
        confirmation_meessage.innerText =
          "Activate a shield for this round?"
        confirmation_action.href = "/leagues/#{league_id}/shield/"
        confirmation_modal.classList.add "is-active"

    if activate_auto_shield
      activate_auto_shield.addEventListener 'click', ->
        confirmation_action.dataset.method = "post"
        confirmation_meessage.innerText =
          "Activate auto shield for the NEXT round?"
        confirmation_action.href = "/leagues/#{league_id}/auto_shield/"
        confirmation_modal.classList.add "is-active"

  tryJoin = ->
    join_private_btn       = document.querySelector    ".join-private-btn"
    join_btn               = document.querySelector    ".join-btn"
    private_form           = document.querySelector    ".private_form"
    public_league          = document.querySelector    ".public_league"
    private_league_message = document.querySelector    ".private_league_message"
    private_cancel         = document.querySelector    ".private_cancel"
    join_form              = document.querySelector    ".join-form"
    league_info            = document.querySelector    "#league-info"
    league_id              = league_info.dataset.leagueid

    if private_cancel
      private_cancel.addEventListener 'click', ->
        confirmation_modal.classList.remove "is-active"
    if join_btn
        join_btn.addEventListener 'click', ->
          public_league.style = 'display: block'
          private_form.style = 'display: none'
          confirmation_modal.classList.add "is-active"
          confirmation_action.href = "/leagues/#{league_id}/join/"
          confirmation_action.dataset.method = "post"
    if join_private_btn
        join_private_btn.addEventListener 'click', ->
          private_form.style = 'display: block'
          public_league.style = 'display: none'
          confirmation_modal.classList.add "is-active"

  if body.className == "leagues_show"
    tryLeverage()
    tryJoin()

tryPassword = ->
  community_select = document.querySelector('#league_community')
  password_input = document.querySelector('#league_password')

  if community_select.value == 'Private'
    password_input.removeAttribute "readonly"
    password_input.setAttribute 'required', true

  community_select.addEventListener 'change', ->
    if community_select.value == 'Public'
      password_input.value = ''
      password_input.setAttribute 'readonly', true
      password_input.removeAttribute "required"
    if community_select.value == 'Private'
      password_input.removeAttribute "readonly"
      password_input.setAttribute 'required', true

document.addEventListener 'turbolinks:load', ->
  body = document.querySelector("body")
  console.log body.className
  if body.className == "leagues_show" || body.className == "leagues_index" || body.className == "leagues_current"
    tryModal()
  else if body.className == "leagues_new"
    tryPassword()
