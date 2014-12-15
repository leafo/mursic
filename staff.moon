
{graphics: g} = love

class Staff extends Box
  line_height: 10

  h: 100
  w: 200
  x: 0
  y: 0

  new: =>
    @h = @line_height * 5

  update: (dt) =>
    true

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

    g.pop!

{ :Staff }

