

class NoteRecorder
  new: (opts) =>
    @midi = assert opts.midi, "missing midi"
    @metronome = assert opts.metronome, "missing metronome"
    @reset!
    @time = 0

    @playback = Sequence ->
      wait_until -> @playback_time
      while true
        wait_until -> next @events

        local last_event
        -- events should be sorted
        for event in *@events
          wait_for_one(
            -> wait_until -> not @playback_time
            -> @playback_time >= event[1]
          )
          break unless @playback_time
          last_event = event
          -- play the event
          @midi.output event[2]

        if @playback_time
          @playback_time -= last_event[1]
          print "reset time to #{@playback_time}"

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
    assert not @recorder, "already started"

    @recorder = Sequence ->
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
      @recorder = nil
      print "Stopped"

  stop: =>
    @stopped = true

    if next @events
      @playback_time = 0

  update: (dt) =>
    @time += dt

    if @playback_time
      dt += 1

    if @record_time
      @record_time += dt

    if @recorder
      @recorder\update dt

    if @playback
      @playback\update dt

{:NoteRecorder}
