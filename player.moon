import keyboard, graphics from love

require "util"
require "geometry"
require "entity"

export Player
export locals

locals: =>
  variables = {}
  idx = 1
  while true do
    ln, lv = debug.getlocal(2, idx)
    if ln ~= nil
      variables[ln] = lv
    else
      break
    idx += 1
  variables

class Player extends Entity
    speed: 200
    w: 20
    h: 20

    new: (world, x=0, y=0) =>
        super world, x, y
        @sprite = imgfy "images/jackie.png"
        @facing = "right"

    move: (dx, dy) =>
        print "move: ", dx, dy
        super dx, dy

    do_gravity: (dt) =>
        -- by adjusting the velocity to a negative, we push the players box
        -- with a specific amount of strength. Afterwards, gravity will push
        -- it down.
        if @on_ground and keyboard.isDown " "
            @velocity[2] = -400
        else
            @velocity += @world.gravity * dt

    do_dx: (dt) =>
        dx = 0
        if keyboard.isDown "left"
            @facing = "left"
            dx = -1
        elseif keyboard.isDown "right"
            @facing = "right"
            dx = 1
        dx

    update: (dt) =>
        -- TODO: 
        -- animate jackie.
        super dt

    draw: =>
        graphics.draw @sprite, @box.x, @box.y
        graphics.print @box.x .. "," .. @box.y, 0, 0
        graphics.print "on_ground " .. tostring(@on_ground), 0, 12
        graphics.print "velocity" .. tostring(@velocity), 0, 36
