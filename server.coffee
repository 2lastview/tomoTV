log = require("single-line-log").stdout
express = require "express"

app = express()

currentFile = 0
currentTime = 1
seconds = 1

# shows with indexes
# 105
# 251
# 47
# 79
# 199
test = [
  name: "zelda"
  length: 105
,
  name: "simpsons"
  length: 251
,
  name: "cc"
  length: 47
,
  name: "nk"
  length: 79
,
  name: "vox"
  length: 199
]

# cuts = [105, 356, 403, 482, 681]
cuts = []
totalTime = 0
for time in test
  totalTime += time.length
  cuts.push totalTime

# second counter
_addSecond = ->
  setTimeout ->
    seconds++
    currentTime++

    for cut, i in cuts
      if cut is seconds
        currentFile = i+1
        currentTime = 1

        if currentFile >= cuts.length
          currentFile = 0
          currentTime = 1
          seconds = 1

    log "i: #{currentFile}\ncurrentFile: #{test[currentFile].name}\ncurrentTime: #{currentTime}\nseconds: #{seconds}\n"

    _addSecond()
  , 1000

app.use (req, res, next) ->
  res.header("Access-Control-Allow-Origin", "*")
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
  next()

app.get "/clock", (req, res) ->
  res.json
    currentFile: currentFile
    currentTime: currentTime

app.get "/info/:index", (req, res) ->
  index = req.params.index
  res.json
    index: currentFile
    name: test[index].name
    totalLength: test[index].length

_addSecond()

app.listen 3000, ->
  console.log "can serve time now"
