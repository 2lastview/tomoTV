coffee -c src/*.coffee
mv src/*.js public/*.js
browserify public/*.js -o public/index.js -d