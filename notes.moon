
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

-- how many letters away a halfstep is
LETTER_OFFSETS = {
  [0]: 0
  [2]: 1
  [4]: 2
  [5]: 3
  [7]: 4
  [9]: 5
  [11]: 6
}

-- how many letters from 0
letter_offset = (pitch) ->
  offset = 0
  while pitch >= 12
    offset += 7
    pitch -= 12

  while not LETTER_OFFSETS[pitch]
    pitch -= 1

  offset + LETTER_OFFSETS[pitch]

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

if ... == "test"
  for i=0,24
    print i, (note_name i), letter_offset i

{ :parse_note, :note_name, :letter_offset, :OFFSETS, :OCTAVE_SIZE }
