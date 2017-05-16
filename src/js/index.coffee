videostream = require "videostream"
WebTorrent = require "webtorrent"
request = require "request"
moment = require "moment"

channels = require "../../config/channels.json"
channelIndex = parseInt document.querySelector("#channelIndex").innerText
channel = channels[channelIndex]

client = new WebTorrent
  downloadLimit: 1024 * 500
  uploadLimit: 1024 * 100

magnet = channel.magnetURI

STREAM_START = "2017-04-01T00:00:00"
current_video = 0
current_time = 0

setCurrentSingleFileInfo = (video) ->
  document.querySelector("#title").innerHTML = video.extracted.title
  document.querySelector("#season").innerHTML = video.extracted.season
  document.querySelector("#episode").innerHTML = video.extracted.episode

client.add magnet, (torrent) ->
  console.log torrent

  torrent.deselect 0, torrent.pieces.length - 1, false

  diff = (moment(new Date()).diff(moment(STREAM_START))) / 1000
  totalDuration = channel.totalDuration
  overallCurrentTime = diff %% totalDuration

  for cut, i in channel.cuts
    if overallCurrentTime < cut
      current_video = i
      current_time = overallCurrentTime

      if i isnt 0
        current_time = overallCurrentTime - channel.cuts[i-1]

      setCurrentSingleFileInfo channel.videos[current_video]
      break

  videoFile = torrent.files[current_video]

  videoElem = document.querySelector("video")
  videostream videoFile, videoElem
  videoElem.currentTime = current_time

  videoElem.addEventListener "ended", ->
    current_video++

    if current_video >= torrent.files.length
      current_video = 0

    console.log torrent.files[current_video]
    videoFile = torrent.files[current_video]
    videostream videoFile, videoElem

    setCurrentSingleFileInfo channel.videos[current_video]

  torrent.on "download", ->
    downloaded.innerHTML = torrent.downloaded / 1024 + " Kb"
    downloadSpeed.innerHTML = torrent.downloadSpeed / 1024 + " Kb/s"
    progress.innerHTML = torrent.progress * 100 + "%"
    strategy.innerHTML = torrent.strategy

  torrent.on "upload", ->
    uploaded.innerHTML = torrent.uploaded / 1024 + " Kb"
    uploadSpeed.innerHTML = torrent.uploadSpeed / 1024 + " Kb/s"
