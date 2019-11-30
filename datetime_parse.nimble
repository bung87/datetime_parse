# Package

version       = "0.1.0"
author        = "bung87"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"

backend       = "js"

# Dependencies

requires "nim >= 1.0.2"

task dist,"dist src/datetime_parse.nim ":
  exec "nim js -d:release -d:nodejs -o:dist/datetime_parse.js src/datetime_parse"

task dev,"run src/datetime_parse.nim ":
  exec "nim c -r src/datetime_parse"