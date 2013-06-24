{exec, spawn} = require 'child_process'
os = require('os').platform()
request = require 'request'
pls = require 'pls'

# http://www.listenlive.eu/uk.html
STATIONS = {
  "FrenchKissFM": "http://stream.frenchkissfm.com:80"
  , "Radio DEEA":"http://live.radiodeea.ro:8090/listen.pls"
  , "Chill": "http://yp.shoutcast.com/sbin/tunein-station.pls?id=651101&file=filename.pls"
  , "BBC 1xtra": "http://www.bbc.co.uk/radio/listen/live/r1x_aaclca.pls"
  , "BBC World Service News":"http://www.bbc.co.uk/worldservice/meta/tx/nb/live/ennws.pls"
  , "BBC World Service":"http://www.bbc.co.uk/worldservice/meta/tx/nb/live/eneuk.pls"
  , "NPR": "http://www.npr.org/streams/mp3/nprlive24.pls"
}

nowPlaying = false

getStation = (current) ->
  stop()

stop = ->
  if nowPlaying
    nowPlaying.kill()

play = (track) ->
  stop()
  if track.match(/\.pls$/)
    request.get track, (err, res, body) ->
      track = pls.parse(body)
      console.log track
      nowPlaying = spawn('mplayer', [track[0].uri])
  else
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
