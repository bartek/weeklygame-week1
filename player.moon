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
    speed: 200
    w: 20
    h: 20

    new: (world, x=0, y=0) =>
        super world, x, y
        @sprite = imgfy "images/jackie.png"
        @facing = "right"
        @time = 0
        @attack_rate = 0.05
        @attacking = false

    move: (dx, dy) =>
        -- print "move: ", dx, dy
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

    attack: (action) =>
        @attacking = action

    do_attack: (dt) =>
        -- ensure we only attack at a certain rate.
        @time += dt
        while @time > @attack_rate
            hit = false
            kill_count = 0
            @time -= @attack_rate

            for enemy in *@world.enemies
                if enemy.box\touches_box @box
                    if @attacking == "punch"
                        if enemy\onhit self
                            play_sound "punch"
                        else
                            kill_count += 1
                            play_sound "slot"
                        hit = true
                        
                if @attacking == "taunt"
                    hit = true
                    enemy\die!
                    play_sound "cheer"

            if @attacking and not hit
                play_sound "woosh"

        @attacking = false
        @attacking

    update: (dt) =>
        -- TODO: 
        -- animate jackie.
        @do_attack dt

        for enemy in *@world.enemies
            if not enemy.hit_cooldown and enemy.box\touches_box @box
                @onhit enemy
                enemy.hit_cooldown = hit_cooldown
                --- bounce!
                @velocity[2] = -200
                @x_knock = -200

        super dt

    draw: =>
        graphics.draw @sprite, @box.x, @box.y
        graphics.print @box.x .. "," .. @box.y, 0, 0
        graphics.print "on_ground " .. tostring(@on_ground), 0, 12
        graphics.print "velocity" .. tostring(@velocity), 0, 36
