{exec, spawn} = require 'child_process'
os = require('os').platform()

STATIONS = {
  "FrenchKissFM": "http://stream.frenchkissfm.com:80"
  , "Radio DEEA":"http://178.157.81.147:8090"
  , "Chill": "http://205.164.62.20:8010"
  , "BBC 1xtra": "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_intl_lc_1xtra_q"
  , "BBC World Service News":"http://bbcwssc.ic.llnwd.net/stream/bbcwssc_mp1_ws-einws"
  , "NPR": "http://npr.ic.llnwd.net/stream/npr_live24"
  , "WSBRadio": "http://6103.live.streamtheworld.com/WSBAMAAC"
}

nowPlaying = false

getStation = (current) ->
  stop()

stop = ->
  if nowPlaying
    nowPlaying.kill()

play = (track) ->
  stop()
  nowPlaying = spawn('mplayer', [track])

volume = (level) ->
  level = level % 10
  if os == 'darwin'
    exec("osascript -e 'set volume #{level}'", ->)
  else
    volumes = [-10239,-3000,-2790,-1790,-1126,-662,-450,-200,0,100,400]
    exec("amixer cset numid=1 -- #{volumes[level]}", ->)

getTrack = (number) ->
  defaultStn = "FrenchKissFM"
  if number
    number = parseInt(number, 10)
    i = 0
    for name, stream of STATIONS
      if number && number == i
        return [name, stream]
      i++
    [defaultStn, STATIONS[defaultStn]]
  else
    [defaultStn, STATIONS[defaultStn]]

module.exports = (robot) ->
  robot.respond /play\s?(.*)?/i, (msg) ->
    if t = msg.match[1]
      [name, stream] = getTrack(t)
      msg.send("Playing #{name}")
      play(stream)
    else
      [name, stream] = getTrack()
      msg.send("Playing #{name}")
      play(stream)

  robot.respond /vol(ume)? ([0-9]{1,2})/i, (msg) ->
    volume(msg.match[2])
    console.log "Setting volume to msg.match[2]"
    msg.send("Volume changed")

  robot.respond /mute/i, (msg) ->
    console.log "Muting audio"
    volume(0)
    msg.send("Muted")

  robot.respond /stop/i, (msg) ->
    stop()
