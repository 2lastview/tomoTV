videostream = require "videostream"
WebTorrent = require "webtorrent"
client = new WebTorrent()
request = require "request"
moment = require "moment"

magnet = "magnet:?xt=urn:btih:13366621b1c346fc72fae77ba00f5303d9544fef&dn=merged.mp4&tr=udp%3A%2F%2Fexplodie.org%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.empire-js.us%3A1337&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=wss%3A%2F%2Ftracker.btorrent.xyz&tr=wss%3A%2F%2Ftracker.fastcast.nz&tr=wss%3A%2F%2Ftracker.openwebtorrent.com"

STREAM_START = "2017-04-01T00:00:00"
CURRENT_SINGLE_FILE = 0

setCurrentSingleFileInfo = (singleFile) ->
  document.querySelector("#title").innerHTML = singleFile.extracted.title
  document.querySelector("#season").innerHTML = singleFile.extracted.season
  document.querySelector("#episode").innerHTML = singleFile.extracted.episode
  document.querySelector("#duration").innerHTML = singleFile.duration + " Sec"
  document.querySelector("#size").innerHTML = singleFile.size / 1024 + " Kb"

client.add magnet, (torrent) ->

  videoFile = torrent.files[0]
  metaFile = torrent.files[1]

  metaFile.getBuffer (err, buffer) ->
    meta = JSON.parse buffer

    # the actual video element
    videoElem = document.querySelector("video")
    videoFile.renderTo videoElem

    # where is stream started
    diff = (moment(new Date()).diff(moment(STREAM_START))) / 1000
    fullDuration = meta.mergedFile.duration
    videoElem.currentTime = diff %% fullDuration

    videoElem.addEventListener "timeupdate", ->
      changed = false
      for cut, i in meta.cuts
        if videoElem.currentTime < cut
          CURRENT_SINGLE_FILE = i
          changed = true
          break

      if changed
        setCurrentSingleFileInfo meta.singleFiles[CURRENT_SINGLE_FILE]

  torrent.on "download", ->
    downloaded.innerHTML = torrent.downloaded / 1024 + " Kb"
    downloadSpeed.innerHTML = torrent.downloadSpeed / 1024 + " Kb/s"
    progress.innerHTML = torrent.progress * 100 + "%"
    strategy.innerHTML = torrent.strategy

  torrent.on "upload", ->
    uploaded.innerHTML = torrent.uploaded / 1024 + " Kb"
    uploadSpeed.innerHTML = torrent.uploadSpeed / 1024 + " Kb/s"
