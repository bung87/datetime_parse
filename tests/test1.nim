import times except parse,join
import timezones
import unittest

import datetime_parse

test "all":
  var init = now()
  check parse("Wednesday, August 21st 2019") != init
  check parse("Nov 8, 2019 / 05:22 PM CST") != init
   