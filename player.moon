import keyboard, graphics from love

require "util"
require "geometry"
require "entity"
require "lovekit.spriter"

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

hit_cooldown = 2.0

class Player extends Entity
    speed: 300
    w: 48
    h: 64
    health: 100
    jump: 500
    punch: { w: 30, h: 10 }

    new: (world, x=0, y=0) =>
        super world, x, y
        -- set padding on the sprite so the box is smaller. collisions to
        -- the human eye look saner.
        sprite = Spriter "images/jackie.png", @w, @h, 0

        @anim = StateAnim "right", {
            right: sprite\seq {0}, 0,
            left: sprite\seq {0}, 0, true
            punch_right: sprite\seq {1}, 0
            punch_left: sprite\seq {1}, 0, true
        }

        @facing = "right"
        @time = 0
        @attack_rate = 0.02
        @attacking = false
        @a_box = nil

    move: (dx, dy) =>
        -- print "move: ", dx, dy
        super dx, dy

    do_gravity: (dt) =>
        -- by adjusting the velocity to a negative, we push the players box
        -- with a specific amount of strength. Afterwards, gravity will push
        -- it down.
        if @on_ground and keyboard.isDown " "
            @velocity[2] = -@jump
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

    attack: (action) =>
        @attacking = action

    do_attack: (dt) =>
        -- ensure we only attack at a certain rate.
        @time += dt
        while @time > @attack_rate
            hit = false
            kill_count = 0
            @time -= @attack_rate

            if @attacking
                -- punch box! the enemy is taking the punch, not our face
                @anim\set_state "punch_" .. @facing
                @anim\draw @box.x, @box.y

                @a_box = Box @box.x + @box.w,
                    @box.y + (@box.h / 2),
                    @punch.w, @punch.h

            for enemy in *@world.enemies
                if @attacking and enemy.alive and enemy.box\touches_box @a_box
                    if @attacking == "punch"
                        if enemy\onhit self
                            play_sound "punch"
                        else
                            kill_count += 1
                            play_sound "slot"

        @a_box = nil
        false

    onhit: (enemy) =>
        enemy.hit_cooldown = hit_cooldown
        --- bounce!
        @velocity[2] = -200
        @x_knock = -200
        @health -= 12
        play_sound "bump"

    update: (dt) =>
        @anim\update dt

        state = @facing
        @anim\set_state state

        hit = @do_attack dt
        if @attacking
            @attacking = false
            if not hit
                play_sound "woosh"

        for enemy in *@world.enemies
            if enemy.alive and enemy.box\touches_box @box
                if not enemy.hit_cooldown
                    @onhit enemy

        super dt

    draw: =>
        @anim\draw @box.x, @box.y
        --graphics.rectangle "line", @box.x, @box.y, @w, @h
        if @a_box
            graphics.rectangle "line",
                @a_box.x, @a_box.y, @punch.w, @punch.h

