import graphics from love
import random from math

require "entity"
require "util"

export Enemy
export EnemySpawner
export Baddie
export Bossman

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
    new: (@enemy_class, @box, rate) =>
        @repeater = Repeater rate, self\spawn
        mixin_object self, @repeater, { "update" }

    -- called when we want to spawn a new baddie.
    spawn: (world) =>
        if @current
            @repeater.time = 0

            -- reset always. endless stream!
            @current = nil
        else
            if @enemy_class == "baddie"
                @current = Baddie world, @box.x, @box.y
            elseif @enemy_class == "bossman"
                @current = Bossman world, @box.x, @box.y
            world\add @current

class Enemy extends Entity
    speed: 150
    type: "enemy"
    alive: true
    health: 10
    hit_cooldown: nil

    new: (...) =>
        super ...
        @facing = "left"

    onhit: (by) =>
        print "I am hit.", self
        @health -= 5
        @die! if @health == 0
        @x_knock = 200
        @velocity[2] = -200
        return @health > 0

    do_dx: (dt) =>
        -- TODO: Know about the world limits.
        if @box.x <= 0
            @facing = "right"
        elseif @box.x >= 800
            @facing = "left"

        if @facing == "left"
            -1
        elseif @facing == "right"
            1

    update: (dt) =>
        if @hit_cooldown
            @hit_cooldown -= dt
            if @hit_cooldown < 0
                @hit_cooldown = nil

        super dt

    die: () =>
        print "I am dead."
        @alive = false

class Baddie extends Enemy
    class: "baddie"

    new: (...) =>
        super ...
        @sprite = imgfy "images/baddie.png"

    draw: =>
        if @alive
            graphics.draw @sprite, @box.x, @box.y

class Bossman extends Enemy
    class: "bossman"

    new: (...) =>
        super ...
        @sprite = imgfy "images/bossman.png"

    draw: =>
        if @alive
            graphics.draw @sprite, @box.x, @box.y
