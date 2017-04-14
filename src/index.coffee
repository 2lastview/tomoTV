videostream = require "videostream"
WebTorrent = require "webtorrent"
client = new WebTorrent()
request = require "request"

magnet = "magnet:?xt=urn:btih:7d0dd9aeb7f525d12201c32980e88b6893d1d65f&dn=1.mp4&tr=udp%3A%2F%2Fexplodie.org%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.empire-js.us%3A1337&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fzer0day.ch%3A1337&tr=wss%3A%2F%2Ftracker.btorrent.xyz&tr=wss%3A%2F%2Ftracker.fastcast.nz&tr=wss%3A%2F%2Ftracker.openwebtorrent.com"

setVideoInfo = (index) ->
  setTimeout ->
    request "http://localhost:3000/info/#{index}", (err, res, body) ->
      body = JSON.parse body

      document.querySelector("#index").innerHTML = body.index
      document.querySelector("#name").innerHTML = body.name
      document.querySelector("#totalLength").innerHTML = body.totalLength
  , 2000

client.add magnet, (torrent) ->

  # get current file and current time
  request "http://localhost:3000/clock", (err, res, body) ->

    body = JSON.parse body

    currentFile = body.currentFile
    currentTime = body.currentTime

    file = torrent.files[currentFile]

    # the actual video element
    videoElem = document.querySelector("video")
    videostream file, videoElem
    videoElem.currentTime = currentTime
    setVideoInfo(currentFile)

    # ended event
    videoElem.addEventListener "ended", ->
      currentFile++
      if currentFile >= torrent.files.length
        currentFile = 0

      file = torrent.files[currentFile]
      videostream file, videoElem
      setVideoInfo(currentFile)

  torrent.on "download", ->
    downloaded.innerHTML = torrent.downloaded/1024 + "Kb"
    downloadSpeed.innerHTML = torrent.downloadSpeed/1024 + "Kb/s"
    progress.innerHTML = torrent.progress * 100 + "%"
    strategy.innerHTML = torrent.strategy

  torrent.on "upload", ->
    uploaded.innerHTML = torrent.uploaded/1024 + "Kb"
    uploadSpeed.innerHTML = torrent.uploadSpeed/1024 + "Kb/s"
