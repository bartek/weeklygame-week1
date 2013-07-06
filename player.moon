import graphics from love

require "util"
require "geometry"

export Player

class Player
    speed: 100
    w: 20
    h: 20

    new: (world, x=0, y=0) =>
        @world = world
        @sprite = imgfy "images/jackie.png"
        @on_ground = false

        @velocity = Vec2d 0, 0
        @box = Box x, y, @w, @h

    move: (dx, dy) =>
        @box.x += dx
        @box.y += dy

    update: (dt) =>
        @velocity += @world.gravity * dt

        dx = 1
        speed = @speed
        speed /= 1.2 if not @on_ground

        delta = Vec2d dx * speed, 0
        delta += @velocity

        delta *= dt
        @move unpack delta

    draw: =>
        graphics.draw @sprite, @box.x, @box.y
