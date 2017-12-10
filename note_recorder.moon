

class NoteRecorder
  new: (opts) =>
    @midi = assert opts.midi, "missing midi"
    @metronome = assert opts.metronome, "missing metronome"
    @reset!
    @time = 0

  reset: =>
    @events = {}
    @event_buffer = {}

  status: =>
    name = @armed and "armed" or @record_time and "recording" or "idle"
    "#{name} #{#@events} #{#@event_buffer}"

  is_recording: =>
    not not @record_time

  on_event: (event) =>
    if @record_time
      table.insert @events, {@record_time, event}
    else
      table.insert @event_buffer, {@time, event}
      while #@event_buffer > 15
        table.remove @event_buffer, 1

  record: =>
    assert not @seq, "already started"

    @seq = Sequence ->
      @armed = true -- will start recording soon

      if @metronome\is_started!
        beat = @metronome.beat_counter
        -- wait until the metronome tocks
        wait_until -> @metronome.beat_counter != beat
      else
        @metronome\start!

      print "Start recording"
      @armed = false
      return if @stopped
      @record_time = 0
      wait_until -> @stopped
      @record_time = nil
      @seq = nil
      print "Stopped"

  stop: =>
    @stopped = true

  update: (dt) =>
    @time += dt

    if @record_time
      @record_time += dt

    if @seq
      @seq\update dt

{:NoteRecorder}
