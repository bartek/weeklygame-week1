import graphics from love
import abs, random from math

require "entity"
require "util"

export Enemy
export EnemySpawner
export Baddie
export Bossman

-- thanks leafo. most code in this module is ripped from his ludum dare
-- game, mostly for learning and tinkering experiences.
-- (https://github.com/leafo)
-- various actions that a monster can do. Need to investigate exactly 
-- how actions get the scope on these variables.
actions = {
  wait: (time) ->
    (dt, world) =>
      time -= dt
      time < 0

  jump: (height) ->
    (dt, world) =>
      @velocity[2] = -height
      true

  move_x: (dist, speed) ->
    dx = 0
    (dt, world) =>
      dx += speed * dt
      a = abs dx

      if a > 1
        dist -= a
        cy, cx = @move dx, 0
        dx = 0
        return true if cx

      dist <= 0
}

class Act
  new: (@entity, @get_next) =>
    @current_action = nil

  update: (dt, world) =>
    if not @current_action
      @current_action = self.get_next!

    if @current_action
      finished = self.current_action @entity, dt, world
      if finished
        @current_action = nil

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

        -- anonymous function created where we randomly choose an action
        @act = Act self, ->
            return false if not @on_ground

            r = random 1,5
            if r > 4
                actions.jump 400
            elseif r > 1
                direction = if random! < 0.5
                            -1 else 1
                actions.move_x 15, direction * 100
            else
                actions.wait 10

    onhit: (by) =>
        print "I am hit.", self
        @health -= 5
        @die! if @health == 0
        @x_knock = 200
        @velocity[2] = -200
        return @health > 0

    do_dx: (dt) =>
        if @box.x <= 0
            @facing = "right"
        elseif @box.x >= screen.width
            @facing = "left"

        if @facing == "left"
            -1
        elseif @facing == "right"
            1

    update: (dt) =>
        if not @alive
            false

        if @hit_cooldown
            @hit_cooldown -= dt
            if @hit_cooldown < 0
                @hit_cooldown = nil

        @act\update dt, world
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
            @sprite\draw @box.x, @box.y

class Bossman extends Enemy
    class: "bossman"

    new: (...) =>
        super ...
        @sprite = imgfy "images/bossman.png"

    draw: =>
        if @alive
            @sprite\draw @box.x, @box.y
