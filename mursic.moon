
{graphics: g} = love

import VList, HList, Bin, Label from require "lovekit.ui"
import GrandStaff from require "staff"
import Metronome from require "metronome"
import NoteRecorder from require "note_recorder"

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
  new: (opts) =>
    super assert opts.parent, "missing parent"
    @on_client = opts.on_client
    @label = opts.label or "choose midi client"
    @refresh_list!

  refresh_list: =>
    clients = for id, name in pairs @parent.midi\list_clients!
      {id, name}

    buttons = VList for tuple in *clients
      Button "#{tuple[2]\lower!}  #{tuple[1]}", (btn) ->
        if @on_client
          @.on_client unpack tuple

        DISPATCHER\pop!

    ui = VList {
      Label @label
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

    @metronome = Metronome @midi, {
      bpm: 90
    }

    @note_recorder = NoteRecorder {
      midi: @midi
      metronome: @metronome
    }

    @seqs\add Sequence ->
      @staff = GrandStaff!

      ui = VList {
        Label "the grand staff"
        @staff
      }

      header = HList {
        Label -> "in: #{@midi.connected_input_name or "none"}"\lower!
        Label -> "out: #{@midi.connected_output_name or "none"}"\lower!
      }

      footer = HList {
        Label ->
          "#{@note_recorder\status!} beat: #{@metronome\format_beat!}"

        Button(
          ->
            if @note_recorder\is_recording!
              "stop"
            else
              "record"

          ->
            if @note_recorder\is_recording!
              @note_recorder\stop!
            else
              @note_recorder\record!
        )

        Button "metronome", ->
          if @metronome\is_started!
            @metronome\stop!
          else
            @metronome\start!

        Button "midi in", ->
          DISPATCHER\push ChooseClientDialog {
            parent: @
            label: "choose midi input device"
            on_client: (...) ->
              @midi\connect_from ...
          }

        Button "midi out", ->
          DISPATCHER\push ChooseClientDialog {
            parent: @
            label: "choose midi output device"
            on_client: (...) ->
              @midi\connect_to ...
          }
      }

      in_viewport = (...) ->
        5, 5, DISPATCHER.viewport.w - 10, DISPATCHER.viewport.h - 10, ...

      @ui = Bin in_viewport ui, 0.5, 0.5
      @ui_footer = Bin in_viewport footer, 1, 1
      @ui_header = Bin in_viewport header, 0, 0

      @staff\append "C3"
      wait 0.1

  on_show: =>
    @midi\flush_events!

  update: (dt) =>
    @seqs\update dt
    @ui\update dt
    @ui_footer\update dt
    @ui_header\update dt
    @metronome\update dt
    @note_recorder\update dt

    while true
      event, raw_event = @midi\next_event!
      break unless event
      @note_recorder\on_event raw_event

      if event.name == "noteon"
        note = event\note_name!
        @staff\append note, 1

        if #@staff.notes > 15
          @staff\shift!

  draw: =>
    @ui\draw!
    @ui_footer\draw!
    @ui_header\draw!

{ :Mursic }
