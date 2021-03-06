
require "lovekit.all"

if pcall(-> require"inotify")
  require "lovekit.reloader"

{graphics: g} = love

import MidiController from require "midi"

load_font = (img, chars)->
  font_image = imgfy img
  g.newImageFont font_image.tex, chars

class MainDispatch extends Dispatcher
  new: (...) =>
    super ...
    @viewport = EffectViewport {
      pixel_scale: true
      crop: true
      scale: GAME_CONFIG.scale
    }

  mouse_pos: =>
    x, y = love.mouse.getPosition!
    @viewport\unproject x, y

love.load = ->
  fonts = {
    default: load_font "images/font.png",
      [[ abcdefghijklmnopqrstuvwxyz-1234567890!.,:;'"?$&]]
  }

  g.setFont fonts.default
  g.setBackgroundColor 10, 10, 10

  import Mursic from require "mursic"

  export DISPATCHER = MainDispatch Mursic!
  -- DISPATCHER.default_transition = FadeTransition
  DISPATCHER\bind love

