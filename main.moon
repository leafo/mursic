
require "lovekit.all"

if pcall(-> require"inotify")
  require "lovekit.reloader"

{graphics: g} = love

import MidiController from require "midi"

load_font = (img, chars)->
  font_image = imgfy img
  g.newImageFont font_image.tex, chars

class PixelViewport extends EffectViewport
  new: (...) =>
    super ...

    screen_w, screen_h = g.getWidth!, g.getHeight!

    @canvas = g.newCanvas screen_w / @scale, screen_h / @scale
    @canvas\setFilter "nearest", "nearest"

  apply: (scale=true) =>
    g.push!
    g.translate @offset_x, @offset_y

    g.setCanvas @canvas
    @canvas\clear 2,2,5, 255

    g.translate -@x, -@y

  pop: =>
    g.pop!
    g.setCanvas!

    g.push!
    g.scale @scale, @scale
    g.draw @canvas, 0, 0
    g.pop!

class MainDispatch extends Dispatcher
  new: (...) =>
    super ...
    @viewport = PixelViewport scale: GAME_CONFIG.scale
    @clicking = {}

  mouse_pos: =>
    x, y = love.mouse.getPosition!
    @viewport\unproject x, y

  just_clicked: (btn="l") =>
    @clicking[btn]

  mousereleased: (...) =>
    x, y, button = ...
    @clicking[button] = true
    super ...

  draw: (...) =>
    @viewport\apply!
    super ...
    @viewport\pop!

  update: (dt) =>
    @viewport\update dt
    super dt

    for k in pairs @clicking
      @clicking[k] = false


love.load = ->
  fonts = {
    default: load_font "images/font.png",
      [[ abcdefghijklmnopqrstuvwxyz-1234567890!.,:;'"?$&]]
  }

  g.setFont fonts.default
  g.setBackgroundColor 10, 10, 10

  import Mursic from require "mursic"

  export DISPATCHER = MainDispatch Mursic!
  DISPATCHER.default_transition = FadeTransition
  DISPATCHER\bind love

