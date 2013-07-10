import setColor from love.graphics
import graphics from love
import random from math

require "util"
require "player"
require "geometry"
require "enemy"

controls = {
    attack: "f"
}

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

class World
    gravity: Vec2d 0, 1000
    new: =>
        @bg = imgfy "images/bg.jpg"
        @enemies = {}
        @_enemies_idx = 1

        @spawners = {
            EnemySpawner "baddie", Vec2d(700, 0), random! * 2,
            EnemySpawner "bossman", Vec2d(700, 0), random! * 10,
        }

    spawn_player: (@player) =>

    -- TODO: We can change "enemies" to be a class object that acts like a list,
    -- and that object can contain these kinds of functions.
    remove_enemy: (index) =>
        print "remove_enemy"
        @enemies[index] = nil

    add: (entity) =>
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
        -- TODO: real tiles, even the most primitive.
        if thing.box.y > 500
            return true

        -- left boundary
        if thing.box.x < 0
            return true

        -- right boundary
        if thing.box.x > 800
            return true

    draw: =>
        graphics.draw @bg, 0, 0
        @player\draw! if @player

        for enemy in *@enemies
            enemy\draw dt

class Game extends GameState
    new: =>
        game = self
        @w = World!
        @player = Player @w, 100, 100
        @w\spawn_player @player
        @paused = false

    update: (dt) =>
        if @paused
            return

        @player\update dt
        @w\update dt

    keypressed: (key, code) =>
        if key == controls.attack
            @player\attack!

        if key == "p"
            @paused = not @paused

        os.exit! if key == "escape"

    draw: =>
        @w\draw!

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

love.draw = ->
    game = Menu!
    game\attach love
