
enum = (tbl) ->
  keys = [k for k in pairs tbl]
  for key in *keys
    tbl[tbl[key]] = key

  tbl

-- low; 36
-- hi; 84
class NoteEvent
  middle_c: 60
  octave_size: 12

  offsets: enum {
    C: 0
    D: 2
    E: 4
    F: 5
    G: 7
    A: 9
    B: 11
  }

  @parse_note: (str) =>
    letter, sharp, flat, octave = str\match "(%w)(#?)(b?)(%d+)"
    sharp = sharp != ""
    flat = flat != ""
    error "note can not be sharp and flat at same time" if sharp and flat
    i = assert(@offsets[letter], "invalid note letter") + tonumber(octave) * @octave_size
    i += 1 if sharp
    i -= 1 if flat
    i

  new: (event_data) =>
    -- { channel, pitch, velocity, unused, duration }
    @channel = event_data[1]
    @pitch = event_data[2]
    @velocity = event_data[3]
    @duration = event_data[5]

  note_name: =>
    print "pitch", @pitch
    octave = math.floor @pitch / @octave_size
    offset = @pitch - octave * @octave_size

    name = @offsets[offset]
    name = @offsets[offset - 1] .. "#" unless name

    "#{name}#{octave}", name, octave

class NoteOnEvent extends NoteEvent
  name: "noteon"

class NoteOffEvent extends NoteEvent
  name: "noteoff"

class MidiController
  new: =>
    @midi = require "midialsa"
    @midi.client "mursic", 1, 0, false

  list_clients: =>
    { k,v for k,v in pairs @midi.listclients! when k != @midi.id! }

  connect_from: (port, name) =>
    @midi.connectfrom 0, name

  connect_to: (port) =>

  create_debug_table: =>
    return if @symbols_by_value

    @symbols_by_value = setmetatable {}, __index: (key) =>
      @[key] = {}
      @[key]

    for key, val in pairs @midi
      continue unless key\match "^[A-Z_]+$"
      table.insert @symbols_by_value[val], key

  flush_events: =>
    while @midi.inputpending! > 0
      @midi.input!

  next_event: =>
    if @midi.inputpending! > 0
      event = @midi.input!
      event_id = event[1]
      event_data = event[8]
      switch event_id
        when @midi.SND_SEQ_EVENT_NOTEON
          NoteOnEvent event_data
        when @midi.SND_SEQ_EVENT_NOTEOFF
          NoteOffEvent event_data
        else
          event

  event_name: (event_id) =>
    @create_debug_table!
    unpack @symbols_by_value[event_id]

{ :MidiController, :NoteEvent }
