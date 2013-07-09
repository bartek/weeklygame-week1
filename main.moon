import setColor from love.graphics
import graphics from love

require "util"
require "player"
require "geometry"

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

    spawn_player: (@player) =>

    collides: (thing) =>
        -- TODO: real tiles, even the most primitive.
        if thing.box.y > 400
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

class Game extends GameState
    new: =>
        game = self
        @w = World!
        @player = Player @w, 100, 100
        @w\spawn_player @player

    update: (dt) =>
        @player\update dt

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
