
enum = (tbl) ->
  keys = [k for k in pairs tbl]
  for key in *keys
    tbl[tbl[key]] = key

  tbl


OCTAVE_SIZE =  12
OFFSETS = enum {
  C: 0
  D: 2
  E: 4
  F: 5
  G: 7
  A: 9
  B: 11
}

parse_note = (str) ->
  letter, sharp, flat, octave = str\match "(%w)(#?)(b?)(%d+)"
  sharp = sharp != ""
  flat = flat != ""
  error "note can not be sharp and flat at same time" if sharp and flat
  i = assert(OFFSETS[letter], "invalid note letter") + tonumber(octave) * OCTAVE_SIZE
  i += 1 if sharp
  i -= 1 if flat
  i

note_name = (pitch) ->
  octave = math.floor pitch / OCTAVE_SIZE
  offset = pitch - octave * OCTAVE_SIZE

  name = OFFSETS[offset]
  name = OFFSETS[offset - 1] .. "#" unless name

  "#{name}#{octave}", name, octave

{ :parse_note, :note_name, :OFFSETS, :OCTAVE_SIZE }
