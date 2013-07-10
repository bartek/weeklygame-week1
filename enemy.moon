import graphics from love
import random from math

require "entity"
require "util"

export Enemy
export EnemySpawner
export Baddie

-- thanks leafo.
-- spawns some hardcoded enemies at repeated random intervals.

class Repeater
    new: (@rate, @action) => @time = @rate * random!

    update: (dt, ...) =>
        @time += dt
        while @time > @rate
            @time -= @rate
            self.action ...
        true

class EnemySpawner
    new: (@box, rate) =>
        @repeater = Repeater rate, self\spawn
        mixin_object self, @repeater, { "update" }

    -- called when we want to spawn a new baddie.
    spawn: (world) =>
        if @current
            @repeater.time = 0

            -- reset always. endless stream!
            @current = nil
        else
            @current = Baddie world, @box.x, @box.y
            world\add @current

class Enemy extends Entity
    speed: 100
    type: "enemy"

class Baddie extends Enemy
    new: (...) =>
        super ...
        @sprite = imgfy "images/baddie.png"

    draw: =>
        graphics.draw @sprite, @box.x, @box.y
