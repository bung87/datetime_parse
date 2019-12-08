# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.
import times except parse,join
import timezones
import unittest
import os
import streams
import datetime_parse

test "corpus":
  var init:DateTime

  let appDir = currentSourcePath().parentDir()

  let corpus = appDir / "corpus.txt"

  var 
      fs = newFileStream(corpus, fmRead)
      line = ""

  if not isNil(fs):
    while fs.readLine(line):
      # echo  line,"==",parse(line)
      check parse(line) != init
    fs.close()
