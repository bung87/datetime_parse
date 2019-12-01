# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.
import times except parse,join
import unittest

import datetime_parse
test "all":
  var init:DateTime
  check parse("2013-01-03") != init
  check parse("Monday, November 25, 2019 11:22 am") != init
  check parse("Monday, November 25, 2019") != init
  check parse("Nov. 8 2019 @ 3:32am") != init
  check parse("31-May-19") != init
  check parse("JUNE 12, 2019 / 11:31 AM") != init
  check parse("9/11/19") != init
  check parse("Tue 12:58 PM, Jul 16, 2019") != init
  check parse("November 20, 2019 at 01:12 PM") != init
  check parse("7/25/19 13:00") != init 
  check parse("23:03, Wed, Nov 13, 2019") != init
  check parse("11/13/19 9:57") != init
  check parse("2019年11月13日 11:00") != init
  check parse("NOV 26, 2019 | 10:00 AM") != init
  check parse("25-Sep-19") != init
  check parse("5-Nov-19") != init
  check parse("JULY 9, 2019 AT 8:47 AM") != init
  check parse("6-Nov-19") != init
  check parse("AUG. 12, 2019 / 1:36 PM") != init
  check parse("April 2, 2019 5:18 PM") != init
  check parse("Nov. 26, 2019") != init
  check parse("2019.11.26 07:15") != init
  check parse("SEPT. 18, 2019 / 12:22 PM") != init
  check parse("Thursday, Nov 07, 2019 07:10 AM") != init
  check parse("Nov 8, 2019 / 05:22 PM CST") != init
  check parse("12:28 PM EST November 16, 2017") != init
