import strscans, unicode, macros, sequtils, strutils, sugar
import times except parse, join
proc ndigits(input: string; intVal: var int; start: int; n: int): int =
  # matches exactly ``n`` digits. Matchers need to return 0 if nothing
  # matched or otherwise the number of processed chars.
  var x = 0
  var i = 0
  while i < n and i+start < input.len and input[i+start] in {'0'..'9'}:
    x = x * 10 + input[i+start].ord - '0'.ord
    inc i
  # only overwrite if we had a match
  # if i == n:
  result = i
  intVal = x

proc year(input: string; intVal: var int; start: int; ): int = ndigits(input,
    intVal, start, 4)

proc hour(input: string; intVal: var int; start: int; ): int = ndigits(input,
    intVal, start, 2)

proc day(input: string; intVal: var int; start: int; ): int = ndigits(input,
    intVal, start, 2)

proc minute(input: string; intVal: var int; start: int; ): int = ndigits(input,
    intVal, start, 2)

const Months = collect(newSeq):
  for e in Month.items:
    let lower = ($e).toLower
    (ord(e), [lower, lower.substr(0, 2), lower.substr(0, 3)])

proc month(input: string; intVal: var int; start: int; ): int =
  var len = 3
  var i = start + len
  var tmp: string
  var r: Rune
  fastRuneAt(input, i, r)
  for e in Months:
    while i < input.len and isAlpha(r):
      fastRuneAt(input, i, r)
      inc len
    tmp = input.substr(start, start + len - 1)
    if tmp in e[1]:
      result = len(tmp)
      intVal = e[0]
      break

const WeekDays = collect(newSeq):
  for e in WeekDay.items:
    let lower = ($e).toLower
    (ord(e), [lower, lower.substr(0, 2), lower.substr(0, 3)])

proc weekday(input: string; intVal: var int; start: int; ): int =
  var len = 3
  var i = start + len
  var tmp: string
  var r: Rune
  fastRuneAt(input, i, r)
  for e in WeekDays:
    while i < input.len and isAlpha(r):
      fastRuneAt(input, i, r)
      inc len
    tmp = input.substr(start, start + len - 1)
    if tmp in e[1]:
      result = len(tmp)
      intVal = e[0]
      break

proc spaces(input: string; start: int; seps: set[char] = {' '}): int =
  result = 0
  while start+result < input.len and input[start+result] in seps: inc result

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

macro pattern(x: varargs[untyped]): string =
  var arr = newSeq[string]()
  for e in x.items:
    var tmp: string
    if e.kind == nnkCall:
      var found = false
      for x in e.items:
        if x.kind == nnkIdent:
          tmp.add(x.strVal)
          if not found:
            tmp.add("(")
            found = true
        elif x.kind == nnkIntLit:
          tmp.add($x.intVal)
        else:
          tmp.add($x)
      tmp.add(")")
      arr.add("${" & tmp & "}")
    elif e.kind == nnkBracket:

      arr.add("$[")
      if len(e) == 0:
        arr.add("spaces")
      else:
        for x in e:
          arr.add($x)
      arr.add("]")
    elif e.kind == nnkIdent:
      arr.add("${" & e.strVal & "}")
    else:
      arr.add($e)
  result = newStrLitNode(arr.join("") & "$.")

proc parse*(input: string): DateTime {.exportc, discardable, noinit.} =
  let input = strutils.strip(input).toLower
  var year, month, weekday, hour, minute, second, day: int
  var tt: string
  if scanf(input, pattern(year, "-", ndigits(2), "-", day), year,
      month, day): #"2013-01-03"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(weekday, ",", [], month, [], day, ",", [], year, [],
      hour, ":", minute, [], tt), weekday,
    month, day, year, hour, minute, tt): #"Monday, November 25, 2019 11:22 am"
    if tt == "pm" and hour < 12:
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(weekday, ",", [], month, [], day, ",", [], year), weekday,
    month, day, year): #"Monday, November 25, 2019"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(month, ".", [], day, [], year, [], "@", [], hour,
      ":", minute, tt), month,
    day, year, hour, minute, tt): #"Nov. 8 2019 @ 3:32am"
    if tt == "pm" and hour < 12:
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(day, "-", month, "-", year), day,
    month, year): # "31-May-19"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(month, [], day, ",", [], year, [], "/", [], hour,
      ":", minute, [], tt), month,
    day, year, hour, minute, tt): # "JUNE 12, 2019 / 11:31 AM"
    if tt == "pm" and hour < 12:
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, [], day, ",", [], year), month,
    day, year): # "JUNE 12, 2019"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(day, [], month, ",", [], year, [], hour, ":",
      minute), day,
    month, year, hour, minute, tt): # "07 Nov, 2019 12:44"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, [], day, ",", [], year, [], "at", [], hour,
      ":", minute, [], tt), month,
    day, year, hour, minute, tt): # "November 20, 2019 at 01:12 PM"
    if tt == "pm" and hour < 12:
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(day, [], month, [], year, [], "at", [], hour, ":",
      minute), day,
    month, year, hour, minute): # "13 AUG 2019 AT 15:54"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(ndigits(2), "/", day, "/", ndigits(2), [], hour,
      ":", minute), month,
    day, year, hour, minute): #"7/25/19 13:00"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(day, "/", ndigits(2), "/", year, [], "-", [], hour,
      ":", minute), day,
    month, year, hour, minute): #"27/08/2019 - 13:54"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(day, "/", ndigits(2), "/", ndigits(2)), day,
    month, year): #"9/11/19"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(day, "/", ndigits(2), "/", ndigits(4)), month,
    day, year): #"03/17/2019"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(weekday, [], hour, ":", minute, [], tt, ",", [],
      month, [], day, ",", [], year),
    weekday, hour, minute, tt, month, day, year): # "Tue 12:58 PM, Jul 16, 2019"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(hour, ":", minute, ",", [], weekday, ",", [], month,
      [], day, ",", [], year)
    , hour, minute, weekday, month, day, year):
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(year, "年", ndigits(2), "月", ndigits(2), "日", [],
      hour, ":", minute)
    , year, month, day, hour, minute): # "2019年11月13日 11:00"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, [], day, ",", [], year, [], "|", [], hour,
      ":", minute, [], tt)
    , month, day, year, hour, minute, tt): # "NOV 26, 2019 | 10:00 AM"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, ".", [], day, ",", [], year, [], "/", [],
      hour, ":", minute, [], tt)
    , month, day, year, hour, minute, tt): # "AUG. 12, 2019 / 1:36 PM"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, [], day, ",", [], year, [], [], hour, ":",
      minute, [], tt)
    , month, day, year, hour, minute, tt): # "April 2, 2019 5:18 PM"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, ".", [], day, ",", [], year)
    , month, day, year): # "Nov. 26, 2019"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(year, ".", ndigits(2), ".", day, [], hour, ":",
      minute, [])
    , year, month, day, hour, minute): # "2019.11.26 07:15"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, [], day, ",", [], year, [], "/", [], hour,
      ":", minute, [], tt, [], "cst")
    , month, day, year, hour, minute, tt): # "Nov 8, 2019 / 05:22 PM CST"
    if tt == "pm" and hour < 12:
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(month, [], day, ",", [], year, ",", [], hour, ":",
      minute, [], tt)
    , month, day, year, hour, minute, tt): # "Nov 21, 2019, 1:34 AM"
    if tt == "pm" and hour < 12:
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(hour, ":", minute, [], tt, [], "est", [], month, [],
      day, ",", [], year)
    , hour, minute, tt, month, day, year): # "12:28 PM EST November 16, 2017"
    if tt == "pm" and hour < 12:
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(weekday, ",", [], month, [], day, "st", [], year)
    , weekday, month, day, year): # "Wednesday, August 21st 2019"
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())

when isMainModule:
  var init: DateTime
  assert parse("Wednesday, August 21st 2019") != init
