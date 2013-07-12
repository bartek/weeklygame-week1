require "geometry"

export Entity

class Entity
    speed: 200
    w: 20
    h: 20

    new: (world, x=0, y=0) =>
        @world = world
        @on_ground = false
        @velocity = Vec2d 0, 0
        @box = Box x, y, @w, @h
        @x_knock = 0

    move: (dx, dy) =>
        collided_x = false
        collided_y = false

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

    do_dx: (dt) =>
        -1

    do_gravity: (dt) =>
        @velocity += @world.gravity * dt

    update: (dt) =>
        dx = @do_dx dt
        @do_gravity dt

        speed = @speed
        speed /= 1.2 if math.abs(@x_knock) > 30

        delta = Vec2d dx * speed, 0
        delta += @velocity

        if @x_knock != 0
            delta[1] += @x_knock
            ax = math.abs(@x_knock)
            if @on_ground
                @x_knock = 0
            elseif ax <= 0.001
                @x_knock = 0
            else
                @x_knock -= 200*dt

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
