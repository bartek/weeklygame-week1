import setColor from love.graphics
import audio, graphics from love
import random from math

require "util"
require "player"
require "geometry"
require "enemy"

controls = {
    attack: "f",
    taunt: "g"
}

sounds = {}

export screen = {
    width: 800
    height: 600
    floor: 500
}

export play_sound = (name) ->
    s = sounds[name]
    if s
        s\rewind!
        s\play!

class GameState
    attach: (love) =>
        love.update = self\update
        love.draw = self\draw
        love.keypressed = self\keypressed
        love.mousepressed = self\mousepressed

    update: =>
    draw: =>
    keypressed: =>
    mousepressed: =>

class HealthBar
    new: =>
        @value = 100
        @max = @value
        @width = 100
        @padding = 10
    
    draw: =>
        x = screen.width - @width - @padding
        y = @padding
        graphics.setColor 255, 255, 255
        graphics.rectangle("line", x - 2, y - 2, @width + 2, 28)

        if math.floor(@max / @value) >= 10
            graphics.setColor 213, 61, 31, 255
        else
            graphics.setColor 87, 219, 31, 255
        graphics.rectangle("fill", x, y, @value, 25)


class World
    gravity: Vec2d 0, 1000
    new: =>
        @bg = imgfy "images/bg.jpg"
        @enemies = {}
        @_enemies_idx = 1

        @spawners = {
            EnemySpawner "baddie", Vec2d(700, 0), random! * 3,
            EnemySpawner "bossman", Vec2d(700, 0), random! * 10,
        }

    spawn_player: (@player) =>

    -- TODO: We can change "enemies" to be a class object that acts like a list,
    -- and that object can contain these kinds of functions.
    remove_enemy: (index) =>
        print "remove_enemy"
        @enemies[index] = nil

    add: (entity) =>
        -- TODO: Gross.
        if entity.type == "enemy"
            @enemies[@_enemies_idx] = entity
            @_enemies_idx += 1

    update: (dt) =>
        -- let the spawner know about the game world.
        for spawner in *@spawners
            spawner\update dt, self

        for enemy in *@enemies
            enemy\update dt

    collides: (thing) =>
        if thing.box.y > screen.floor
            return true

        -- left boundary
        if thing.box.x < 0
            return true

        -- right boundary
        if thing.box.x > screen.width
            return true

    draw: =>
        -- reset colour
        graphics.setColor 255, 255, 255
        graphics.draw @bg, 0, 0
        @player\draw! if @player

        for enemy in *@enemies
            enemy\draw dt

class GameOver extends GameState
    new: (@game, @time) =>
    keypressed: (key, code) =>
        if key == "return"
            -- Blow the world up!
            @game.start = love.timer.getTime()
            for enemy in *@game.w.enemies
                enemy\die!
                play_sound "cheer"

            @game.player.health = 100
            @game\attach love

    draw: =>
        graphics.setColor 213, 61, 197
        x = screen.width / 2
        y = screen.height / 2

        graphics.print "JACKIE TOOK", x - 100, y,
                0, 2, 2, 0, 0
        graphics.print @time .. " SECONDS", x - 100, y + 50,
                0, 2, 2, 0, 0
        graphics.print "OF PAIN", x - 100, y + 100,
                0, 2, 2, 0, 0

class Game extends GameState
    new: =>
        game = self
        @w = World!
        @player = Player @w, 100, 100
        @w\spawn_player @player
        @paused = false
        @health_bar = HealthBar!

        -- start game timer
        @start = love.timer.getTime()

    update: (dt) =>
        if @paused
            return

        if @player.health <= 0
            time = math.ceil(love.timer.getTime() - @start)
            GameOver(self, time)\attach love
            return

        @player\update dt
        @health_bar.value = @player.health
        @w\update dt

    keypressed: (key, code) =>
        if key == controls.attack
            @player\attack "punch"
        elseif key == controls.taunt
            @player\attack "taunt"

        if key == "p"
            @paused = not @paused

        os.exit! if key == "escape"

    draw: =>
        @w\draw!
        @health_bar\draw!

class Menu extends GameState
    new: =>
        @title = "Jackie Chan's Casino Orchestra!"

    draw: =>
        setColor 255,255,255,255
        graphics.print @title, 300, 100

    update: (dt) =>
        if @game
            print "load time", dt
            @game\attach love

    keypressed: (key, code) =>
        if key == "return"
            @game = Game!

        os.exit! if key == "escape"

love.load = ->
    sounds.woosh = audio.newSource "sounds/woosh.wav", "static"
    sounds.punch = audio.newSource "sounds/punch.wav", "static"
    sounds.slot = audio.newSource "sounds/slot.wav", "static"
    sounds.cheer = audio.newSource "sounds/cheer.wav", "static"
    sounds.bump = audio.newSource "sounds/bump.wav", "static"

    background = audio.newSource "sounds/turkish-patrol.ogg", "streaming"
    background\setLooping true
    background\play!

    game = Menu!
    game\attach love
