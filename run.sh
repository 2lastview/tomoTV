coffee -c src/index.coffee
mv src/index.js public/index.js
browserify public/index.js -o public/index.js -d
coffee server.coffee
