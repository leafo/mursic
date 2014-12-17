
{graphics: g} = love

import parse_note, letter_offset from require "notes"

class NoteBuffer
  time: 0 -- beats elapsed

  append: (note, duration) =>
    table.insert @, {note, duration}

class Staff extends Box
  line_height: 12
  beat_width: 20
  note_size: 8

  h: 100
  w: 300
  x: 0
  y: 0

  new: (middle_note) =>
    @middle_note = assert parse_note middle_note

    @h = @line_height * 6
    @notes = NoteBuffer!

  update: (dt) =>
    true

  note_offset: (n) =>
    pitch = parse_note n
    delta = letter_offset(pitch) - letter_offset(@middle_note)
    mid = (@line_height * 3)
    math.floor -delta * (@line_height / 2) + mid

  draw_note: (x,y, duration) =>
    border = 3
    half = @note_size / 2
    half_border = border / 2

    g.push!
    g.translate x, y

    g.rotate math.pi / 4

    COLOR\push 255, 255,255
    g.rectangle "fill", -(half + half_border), -(half + half_border),
      @note_size + border, @note_size + border
    COLOR\pop!

    COLOR\push 20, 20, 20
    g.rectangle "fill", -half, -half, @note_size, @note_size
    COLOR\pop!

    g.pop!

  draw: =>
    g.push!
    g.translate @x, @y

    for i=1,5
      offset_y = i * @line_height
      COLOR\pusha 100
      g.rectangle "fill", 0, offset_y, @w, 1
      COLOR\pop!

      COLOR\pusha 40
      g.rectangle "fill", 0, offset_y + 1, @w, 1
      COLOR\pop!

    -- g.rectangle "line", 0, 0, @w, @h

    if @notes
      i = 1

      for {note, dur} in *@notes
        x = i * @beat_width
        @draw_note x, @note_offset note
        i += dur

    g.pop!

{ :Staff }

