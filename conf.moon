export GAME_CONFIG = {
  scale: 2
}

love.conf = (t) ->
  t.window.width = 420 * GAME_CONFIG.scale
  t.window.height = 272 * GAME_CONFIG.scale

  t.title = "mursic"
  t.author = "leafo"
