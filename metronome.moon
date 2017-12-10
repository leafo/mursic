class Metronome
  new: (@midi, opts={}) =>
    @bpm = opts.bpm or 60
    @subdivisions = opts.subdivisions or 4
    @time = 0
    @channel = opts.channel or 10
    @timers = DrawList!

  is_started: =>
    @beat

  start: =>
    @beat = 0
    @beat_counter = 0

  stop: =>
    @beat = nil
    @beat_counter = 0

  tick: (note=75) =>
    return unless @midi.connected_output_name

    @midi\note_on 9, note, 100
    @timers\add Sequence ->
      wait 0.1
      @midi\note_off 9, note

  format_beat: =>
    if @beat
      "%0.1f"\format @get_beat!
    else
      "off"

  get_beat: =>
    @beat_counter + @beat

  update: (dt) =>
    @time += dt
    @timers\update dt

    if @beat
      @beat += dt / 60 * @bpm

      if @beat > 1
        @beat -= 1
        @beat_counter += 1
        if (@beat_counter - 1) % @subdivisions == 0
          @tick 76
        else
          @tick!



{:Metronome}
