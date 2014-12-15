
class MidiController
  new: =>
    @midi = require "midialsa"
    @midi.client "mursic", 1, 0, false

  list_clients: =>
    @midi.listclients!

  create_debug_table: =>
    @symbols_by_value = setmetatable {}, __index: (key) =>
      @[key] = {}
      @[key]

    for key, val in pairs @midi
      continue unless key\match "^[A-Z_]+$"
      table.insert @symbols_by_value[val], key

  next_event: =>
    if midi.inputpending! > 0
      midi.input!



{ :MidiController }
