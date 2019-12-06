import times except parse,join
import timezones
import unittest

import datetime_parse

test "all":
  var init:DateTime
  echo parse("Wednesday, August 21 2019"),init
  check parse("Wednesday, August 21 2019") != init
   