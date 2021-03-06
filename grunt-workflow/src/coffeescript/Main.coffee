Physics = require './Physics.coffee'

html5.ready ->
  physics = new Physics(Config)
  physics.init()

  click.addEventListener "click", -> window.open html5.getClickTag(), "_blank"

  canvas = document.getElementsByTagName("canvas")[0]
  canvas.onclick = canvas.ontouchstart = ->
    if canvas.height == Config.expandedHeight
      [canvas.width, canvas.height] = [Config.width, Config.height]
      physics.contract()
    else
      [canvas.width, canvas.height] = [Config.expandedWidth, Config.expandedHeight]
      physics.expand()

  html5.expanding.follow canvas
