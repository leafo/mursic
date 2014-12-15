
{graphics: g} = love

import parse_note from require "notes"

class NoteBuffer
  time: 0 -- beats elapsed

  append: (note, duration) =>
    table.insert @, {note, duration}

class Staff extends Box
  line_height: 12
  beat_width: 10
  note_size: 5

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
    dpitch = pitch - @middle_note
    mid = (@line_height * 3)
    math.floor -dpitch * @line_height / 2 + mid

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

    g.rectangle "line", 0, 0, @w, @h

    if @notes
      for i, {note, dur} in ipairs @notes
        x = i * @beat_width
        g.push!
        g.translate -@note_size / 2, -@note_size / 2
        g.rectangle "fill", x, @note_offset(note), @note_size, @note_size
        g.pop!

    g.pop!

{ :Staff }

