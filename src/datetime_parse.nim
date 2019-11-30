import strscans
import times except parse
proc ndigits(input: string; intVal: var int; start: int; n: int): int =
  # matches exactly ``n`` digits. Matchers need to return 0 if nothing
  # matched or otherwise the number of processed chars.
  var x = 0
  var i = 0
  while i < n and i+start < input.len and input[i+start] in {'0'..'9'}:
    x = x * 10 + input[i+start].ord - '0'.ord
    inc i
  # only overwrite if we had a match
  if i == n:
    result = n
    intVal = x

proc month(input: string; intVal: var int; start: int; ): int =
  var i, len = 0
  var tmp: string
  for e in Month.items:
    i = 0
    len = len($e)
    while i+start < input.len:
      tmp = input.substr(i+start, i+start + len - 1)
      if tmp == $e:
        result = len
        intVal = ord(e)
      inc i

proc spaces(input: string; start: int; seps: set[char] = {' '}): int =
  result = 0
  while start+result < input.len and input[start+result] in seps: inc result

proc weekday(input: string; intVal: var int; start: int; ): int =
  var i, len = 0
  var tmp: string
  for e in WeekDay.items:
    i = 0
    len = len($e)
    while i+start < input.len:
      tmp = input.substr(i+start, i+start + len - 1)
      if tmp == $e:
        result = len
        intVal = ord(e)
      inc i

proc tt(input: string; strVal: var string; start: int; ): int =
  var i, len = 0
  var tmp: string
  for e in ["am", "pm"].items:
    i = 0
    len = len(e)
    while i+start < input.len:
      tmp = input.substr(i+start, i+start + len - 1)
      if tmp == e:
        result = len
        strVal = e
      inc i

proc parse*(input: string): DateTime {.exportc.} =
  var year, month, weekday, hour, minute, second, day: int
  var tt: string
  if scanf(input, "${ndigits(4)}-${ndigits(2)}-${ndigits(2)}$.", year,
      month, day):
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, "${weekday},$[spaces]${month}$[spaces]${ndigits(2)},$[spaces]${ndigits(4)}$[spaces]${ndigits(2)}:${ndigits(2)}$[spaces]${tt}$.", weekday,
    month, day, year, hour, minute, tt):
    if tt == "pm" :
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, "${weekday},$[spaces]${month}$[spaces]${ndigits(2)},$[spaces]${ndigits(4)}$.", weekday,
    month, day, year):
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
    
when isMainModule:
  echo parse("2013-01-03")
  echo parse("Monday, November 25, 2019 11:22 am")
  echo parse("Monday, November 25, 2019")
  echo parse("Nov. 8 2019 @ 3:32am")
  echo parse("31-May-19")
  echo parse("JUNE 12, 2019 / 11:31 AM")
  echo parse("9/11/19")
  echo parse("Tue 12:58 PM, Jul 16, 2019")
  echo parse("November 20, 2019 at 01:12 PM")
  echo parse("7/25/19 13:00")
  echo parse("23:03, Wed, Nov 13, 2019")
