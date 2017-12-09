
{graphics: g} = love

import VList, HList, Bin, Label from require "lovekit.ui"
import GrandStaff from require "staff"

class StackedView
  new: (@parent) =>

  draw: =>
    COLOR\pusha 100
    @parent\draw!
    COLOR\pop!

class Button extends Label
  padding: 5

  new: (label, callback) =>
    super label
    if type(callback) == "function"
      @callback = callback

    @seq = Sequence ->
      while true
        wait_until -> @hovering
        wait_for_one(
          -> wait_until -> not @hovering
          ->
            wait_until -> not love.mouse.isDown 1
            wait_until -> love.mouse.isDown 1
            if @callback
              @callback @
        )

  _set_size: (...) =>
    super ...
    @w += @padding * 2
    @h += @padding * 2

  update: (dt) =>
    x,y = DISPATCHER\mouse_pos!
    @hovering = @touches_pt x,y
    @seq\update dt

    super dt

  draw: =>
    shade1 = if @hovering then 40 else 30
    shade2 = if @hovering then 90 else 80

    COLOR\push shade1, shade1, shade1
    g.rectangle "fill", @unpack!
    COLOR\pop!

    COLOR\push shade2, shade2, shade2
    g.rectangle "line", @unpack!
    COLOR\pop!

    g.push!
    g.translate @padding, @padding
    super!
    g.pop!

class ChooseClientDialog extends StackedView
  new: (@parent) =>
    @refresh_list!

  refresh_list: =>
    @clients = [{id, name} for id, name in pairs @parent.midi\list_clients!]
    buttons = VList for tuple in *@clients
      Button "#{tuple[2]\lower!}     #{tuple[1]}", (btn) ->
        @parent.midi\connect_from unpack tuple
        DISPATCHER\pop!

    ui = VList {
      Label "choose a client to read from"
      Box 0,0,150, 2
      buttons
      Box 0,0,150, 2
      Button "cancel", => DISPATCHER\pop!
    }

    @ui = Bin 0, 0, DISPATCHER.viewport.w, DISPATCHER.viewport.h, ui, 0.5, 0.5

  update: (dt) =>
    @ui\update dt

  draw: =>
    super!
    @ui\draw!

class Mursic
  new: =>
    @seqs = DrawList!

    import MidiController from require "midi"
    @midi = MidiController!

    @seqs\add Sequence ->
      @staff = GrandStaff!

      ui = VList {
        Label "the grand staff"
        @staff
      }

      footer = HList {
        Button "midi in", ->
          DISPATCHER\push ChooseClientDialog @

        Button "midi out", ->
          error "not yet"
      }

      in_viewport = (...) ->
        5, 5, DISPATCHER.viewport.w - 10, DISPATCHER.viewport.h - 10, ...

      @ui = Bin in_viewport ui, 0.5, 0.5
      @ui_footer = Bin in_viewport footer, 1, 1

      @staff\append "D3"
      @staff\append "A3"
      @staff\append "B3"
      @staff\append "A5"
      @staff\append "C5"
      @staff\append "D5"
      @staff\append "G5"
      @staff\append "C6"
      @staff\append "G6"
      @staff\append "A6"
      @staff\append "C5", 2
      @staff\append "C6", 2
      @staff\append "C7", 2

      wait 0.1

  on_show: =>
    @midi\flush_events!

  update: (dt) =>
    @seqs\update dt
    @ui\update dt
    @ui_footer\update dt

    while true
      event = @midi\next_event!
      break unless event
      if event.name == "noteon"
        note = event\note_name!
        @staff\append note, 2

  draw: =>
    @ui\draw!
    @ui_footer\draw!

{ :Mursic }
