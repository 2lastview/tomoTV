fs = require "fs"
gulp = require "gulp"
runSequence = require "run-sequence"
$ = require("gulp-load-plugins")
  pattern: ["gulp-*"]
rename = require "gulp-rename"
template = require "gulp-template"
hb = require "gulp-compile-handlebars"
rename = require "gulp-rename"
browserify = require "gulp-browserify"
request = require "request"

channels = null

coffeePipe = (input) ->
  input.pipe $.coffee
    bare: true
  .pipe gulp.dest "./public/js"

gulp.task "default", (done) ->
  runSequence "config", "coffee", "template-generator", done

gulp.task "config", ->
  request "http://5.79.64.19:4000/channels", (err, res, body) ->
    if err?
      throw err

    channels = JSON.parse body
    fs.writeFileSync "./config/channels.json", body

gulp.task "coffee", ->
  coffeePipe gulp.src("./src/js/index.coffee")

gulp.task "browserify", ->
  gulp.src "./public/js/index.js"
  .pipe browserify()
  .pipe gulp.dest("./public/js")

gulp.task "template-generator", ->
  options =
    ignorePartials: false
    batch: ["./src"]

  # create index
  gulp.src "./src/index.handlebars"
  .pipe hb(channels: channels, options)
  .pipe rename("index.html")
  .pipe gulp.dest("./public")

  # create channels
  channels.forEach (channel, channelIndex) ->
    gulp.src "./src/channel.handlebars"
    .pipe hb({name: channel.name, channelIndex: channelIndex}, options)
    .pipe rename("#{channel.id}.html")
    .pipe gulp.dest("./public")
