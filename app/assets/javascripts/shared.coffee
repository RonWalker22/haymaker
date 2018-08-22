tryShared = ->
  burger = document.querySelector '.navbar-burger'
  menu   = document.querySelector '.navbar-menu'

  burger.addEventListener 'click', ->
    if menu.classList.contains 'is-active'
      menu.classList.remove 'is-active'
      burger.classList.remove 'is-active'
    else
      menu.classList.add 'is-active'
      burger.classList.add 'is-active'


document.addEventListener 'turbolinks:load', ->
  tryShared()
