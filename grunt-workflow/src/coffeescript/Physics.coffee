class Physics
  Engine = Matter.Engine
  World = Matter.World
  Bodies = Matter.Bodies

  constructor: (@config) ->

  init: ->
    @engine = Engine.create
      render:
        element: document.getElementById("viewport")
        options:
          width: @config.width
          height: @config.height
          wireframes: false

    @ground = Bodies.rectangle(@config.width / 2, @config.height + 23, @config.width, 40, { isStatic: true })
    left = Bodies.rectangle(-23, 0, 40, 1000, { isStatic: true })
    right = Bodies.rectangle(@config.width + 23, 0, 40, 1000, { isStatic: true })

    World.add(@engine.world, [@ground, left, right])
    Engine.run(@engine)
    window.setInterval (=> @spawn()), 500

  spawn: ->
    logo = Bodies.polygon Math.random() * @config.width, 0, 3, 50,
      render:
        sprite:
          texture: "assets/delta-logo.png"
          xScale: 0.25
          yScale: 0.25
    Matter.Body.rotate(logo, Math.random() * 360)
    World.add(@engine.world, [logo])
    window.setTimeout (=> World.remove(@engine.world, [logo])), 30000

  expand: -> Matter.Body.translate(@ground, {x: 0, y: @config.expandedHeight - @config.height})
  contract: -> Matter.Body.translate(@ground, {x: 0, y: -(@config.expandedHeight - @config.height)})

module?.exports = Physics
