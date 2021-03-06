
-- low; 36
-- hi; 84
class NoteEvent
  middle_c: 60

  new: (event_data) =>
    -- { channel, pitch, velocity, unused, duration }
    @channel = event_data[1]
    @pitch = event_data[2]
    @velocity = event_data[3]
    @duration = event_data[5]

  note_name: =>
    import note_name from require "notes"
    note_name @pitch

class NoteOnEvent extends NoteEvent
  name: "noteon"

class NoteOffEvent extends NoteEvent
  name: "noteoff"

class MidiController
  new: =>
    @midi = require "midialsa"
    @midi.client "mursic", 1, 1, false

  list_clients: =>
    { k,v for k,v in pairs @midi.listclients! when k != @midi.id! }

  connect_from: (port, name) =>
    @connected_input_name = name
    @midi.connectfrom 0, name

  connect_to: (port, name) =>
    @connected_output_name = name
    @midi.connectto 0, name

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

  note_on: (channel, pitch, velocity) =>
    @midi.output @midi.noteonevent channel, pitch, velocity

  note_off: (channel, pitch) =>
    @midi.output @midi.noteoffevent channel, pitch, 0

  next_event: =>
    if @midi.inputpending! > 0
      event = @midi.input!

      if @connected_output_name
        @midi.output event

      event_id = event[1]
      event_data = event[8]

      wrapped_event = switch event_id
        when @midi.SND_SEQ_EVENT_NOTEON
          if event_data[3] == 0
            NoteOffEvent event_data
          else
            NoteOnEvent event_data
        when @midi.SND_SEQ_EVENT_NOTEOFF
          NoteOffEvent event_data
        else
          event

      wrapped_event, event_data

  event_name: (event_id) =>
    @create_debug_table!
    unpack @symbols_by_value[event_id]

{ :MidiController, :NoteEvent }
