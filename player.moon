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

hit_cooldown = 2.0

class Player extends Entity
    speed: 300
    w: 40
    h: 60
    health: 100
    jump: 500
    punch: { w: 30, h: 10 }

    new: (world, x=0, y=0) =>
        super world, x, y
        @sprite = imgfy "images/jackie.png"
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
                        
                if @attacking == "taunt"
                    hit = true
                    enemy\die!
                    play_sound "cheer"

        @attacking = false
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
        -- TODO: 
        -- animate jackie.
        hit = @do_attack dt
        if @attacking and not hit
            play_sound "woosh"

        for enemy in *@world.enemies
            if enemy.alive and enemy.box\touches_box @box
                if not enemy.hit_cooldown
                    @onhit enemy

        super dt

    draw: =>
        graphics.draw @sprite, @box.x, @box.y
        graphics.rectangle "line",
            @box.x, @box.y, @w, @h
        if @a_box
            graphics.rectangle "line",
                @a_box.x, @a_box.y, @punch.w, @punch.h

