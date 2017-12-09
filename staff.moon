
{graphics: g} = love

import parse_note, letter_offset, MIDDLE_C_PITCH from require "notes"
import VList from require "lovekit.ui"

class NoteBuffer
  time: 0 -- beats elapsed

  new: (opts) =>
    for k,v in pairs opts
      @[k] = v

  append: (note, duration=1) =>
    table.insert @, {note, duration}

  should_draw: (clef) =>
    true

class Staff extends Box
  line_height: 12
  beat_width: 20
  note_size: 8
  staff_lines: 5
  clef_margin: 40

  h: 100
  w: 350
  x: 0
  y: 0

  new: (@middle_note_name, @notes) =>
    @middle_note = assert parse_note @middle_note_name
    @h = @line_height * 6

  update: (dt) =>
    true

  shift: =>
    table.remove @notes, 1

  append: (...) =>
    assert(@notes, "no notes buffer on clef")\append ...

  note_offset: (n) =>
    pitch = parse_note n
    delta = letter_offset(pitch) - letter_offset(@middle_note)
    mid = (@line_height * 3)
    math.floor -delta * (@line_height / 2) + mid

  draw_note: (x,y, duration) =>
    -- ledger lines
    line_offset = y / @line_height
    line_offset = if line_offset < 1
      math.ceil line_offset
    else
      math.floor line_offset

    while line_offset < 1 or line_offset > @staff_lines
      offset_y = line_offset * @line_height
      @draw_staff_line x - (@beat_width / 2), offset_y, @beat_width
      if line_offset < 1
        line_offset +=1
      else
        line_offset -=1

    -- the note
    border = 3
    half = @note_size / 2
    half_border = border / 2

    g.push!
    g.translate x, y

    g.rotate math.pi / 180 * -10
    g.scale 1, 0.75

    g.rotate math.pi / 4

    COLOR\push 255, 255,255
    g.rectangle "fill", -(half + half_border), -(half + half_border),
      @note_size + border, @note_size + border
    COLOR\pop!

    COLOR\push 20, 20, 20
    g.rectangle "fill", -half, -half, @note_size, @note_size
    COLOR\pop!

    g.pop!


  draw_staff_line: (x,y,w) =>
    COLOR\pusha 100
    g.rectangle "fill", x, y, w, 1
    COLOR\pop!

    COLOR\pusha 40
    g.rectangle "fill", x, y + 1, w, 1
    COLOR\pop!

  draw_clef: =>

  draw: =>
    -- COLOR\pusha 20
    -- g.rectangle "fill", @unpack!
    -- COLOR\pop!

    g.push!
    g.translate @x + @clef_margin, @y

    @draw_clef!

    for i=1,@staff_lines
      offset_y = i * @line_height
      @draw_staff_line 0, offset_y, @w - @clef_margin

    if @notes
      i = 1
      for {note, dur} in *@notes
        x = i * @beat_width
        if @notes\should_draw @, note
          @draw_note x, @note_offset note
        i += dur

    g.pop!

class TrebleStaff extends Staff
  new: (...) =>
    super "B5", ...
    @clef_img = imgfy "images/treble-clef.png"

  draw_clef: =>
    COLOR\pusha 200
    @clef_img\draw -(@clef_img\width! + 4), 0
    COLOR\pop!

class BassStaff extends Staff
  new: (...) =>
    super "D4", ...
    @clef_img = imgfy "images/bass-clef.png"

  draw_clef: =>
    COLOR\pusha 200
    @clef_img\draw -(@clef_img\width! + 4), @line_height
    COLOR\pop!


class GrandStaff extends VList
  padding: 0

  new: =>
    @notes = NoteBuffer {
      should_draw: (buffer, clef, note) ->
        pitch = parse_note note

        if clef == @bass_staff
          pitch < MIDDLE_C_PITCH
        else
          pitch >= MIDDLE_C_PITCH
    }

    @bass_staff = BassStaff @notes
    @treble_staff = TrebleStaff @notes

    super {
      @treble_staff
      @bass_staff
    }

  shift: =>
    table.remove @notes, 1

  append: (...) =>
    @notes\append ...

{ :Staff, :TrebleStaff, :BassStaff, :GrandStaff }
