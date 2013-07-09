import keyboard, graphics from love

require "util"
require "geometry"

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

class Player
    speed: 200
    w: 20
    h: 20

    new: (world, x=0, y=0) =>
        @world = world
        @sprite = imgfy "images/jackie.png"
        @on_ground = false

        @velocity = Vec2d 0, 0
        @box = Box x, y, @w, @h

        @facing = "right"

    move: (dx, dy) =>
        collided_x = false
        collided_y = false

        print "move: ", dx, dy

        @facing = "right" if dx > 0
        @facing = "left" if dx < 0

        if dx > 0
            start = @box.x
            @box.x += dx
            if @world\collides self
                @box.x = floor @box.x
                while @world\collides self
                    collided_x = true
                    @box.x -= 1
        elseif dx < 0
            start = @box.x
            @box.x += dx
            if @world\collides self
                @box.x = ceil @box.x
                while @world\collides self
                    collided_x = true
                    @box.x += 1

        -- hit floor
        if dy > 0
            start = @box.y
            @box.y += dy
            if @world\collides self
                @box.y = floor @box.y
                while @world\collides self
                    collided_y = true
                    @box.y -= 1
        -- hit ceiling
        elseif dy < 0
            start = @box.y
            @box.y += dy
            if @world\collides self
                @box.y = ceil @box.y
                while @world\collides self
                    collided_y = true
                    @box.y += 1

        collided_y, collided_x

    update: (dt) =>
        -- TODO: 
        -- animate jackie.

        dx = 0
        if keyboard.isDown "left"
            @facing = "left"
            dx = -1
        elseif keyboard.isDown "right"
            @facing = "right"
            dx = 1

        -- by adjusting the velocity to a negative, we push the players box
        -- with a specific amount of strength. Afterwards, gravity will push
        -- it down.
        if @on_ground and keyboard.isDown " "
            @velocity[2] = -400
        else
            @velocity += @world.gravity * dt

        speed = @speed
        delta = Vec2d dx * speed, 0
        delta += @velocity

        delta[1] = @speed if delta[1] > @speed
        delta[1] = -@speed if delta[1] < -@speed

        delta *= dt

        -- move will return a a nil on the second variable if it
        -- doesnt exist, or we can safely ignore it in this case.
        collided_y = @move unpack delta
        if collided_y
            @velocity[2] = 0
            if delta.y > 0
                @on_ground = true
        else
            if math.floor(delta.y) != 0
                @on_ground = false

    draw: =>
        graphics.draw @sprite, @box.x, @box.y
        graphics.print @box.x .. "," .. @box.y, 0, 0
        graphics.print "on_ground " .. tostring(@on_ground), 0, 12
        graphics.print "velocity" .. tostring(@velocity), 0, 36
