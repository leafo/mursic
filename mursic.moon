
{graphics: g} = love

import VList, HList, Bin, Label from require "lovekit.ui"
import Staff from require "staff"

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

  _set_size: (...) =>
    super ...
    @w += @padding * 2
    @h += @padding * 2

  update: (dt) =>
    x,y = DISPATCHER\mouse_pos!
    @hovering = @touches_pt x,y

    if @hovering and DISPATCHER\just_clicked!
      if @callback
        @callback @

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
      @staff = Staff "B5"

      ui = VList {
        Label "the staff"
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
        @staff.notes\append note, 1

  draw: =>
    @ui\draw!
    @ui_footer\draw!

{ :Mursic }
