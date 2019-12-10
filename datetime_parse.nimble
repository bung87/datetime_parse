# Package

version       = "0.1.0"
author        = "bung87"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"

backend       = "c"

# Dependencies

requires "nim >= 1.1.1"
requires "timezones >= 0.5.1"

task dist,"dist src/datetime_parse.nim ":
  exec "nim js --taintMode:off -d:release -d:nodejs --checks:on -o:dist/datetime_parse.js src/datetime_parse"


task buildjs,"build src/datetime_parse.nim ":
  exec "nim js --taintMode:off  -d:nodejs --checks:on -o:build/datetime_parse.js src/datetime_parse"


task tests, "Runs the test suite":
  exec "nimble test"
  exec "nimble buildjs && node tests/test3.js"