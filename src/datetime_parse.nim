import strscans, unicode, macros, strutils, sugar
import times except parse, join
import timezones #except initDateTime

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

proc tz(input: string; strVal: var string; start: int; ): int =
  var tzs: seq[string] = collect(newSeq):
    for x in tzNames(getDefaultTzDb()):
      x.toLower

  var i = 0
  while i+start < input.len and input[i+start] in {'a'..'z', '-', '/', '_'}:
    inc i
  var lower = input[start..i+start - 1]
  if lower == "cst":
    lower = "cst6cdt"
  if lower in tzs:
    result = i
    strVal = if lower.contains('/'): lower.capitalize else: lower.toUpper

proc year(input: string; intVal: var int; start: int;n = 4 ): int = 
  var x = 0
  var i = 0
  while i < n and i+start < input.len and input[i+start] in {'0'..'9'}:
    x = x * 10 + input[i+start].ord - '0'.ord
    inc i
  # only overwrite if we had a match
  if i == n:
    result = i
    intVal = x

proc year2(input: string; intVal: var int; start: int;n = 2 ): int = 
  var x = 0
  var i = 0
  while i < n and i+start < input.len and input[i+start] in {'0'..'9'}:
    x = x * 10 + input[i+start].ord - '0'.ord
    inc i
  # only overwrite if we had a match
  if i == n:
    result = i
    intVal = x

proc monthdigit(input: string; intVal: var int; start: int; ): int = ndigits(
    input, intVal, start, 2)

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

macro pattern(input: string; x: varargs[untyped]): untyped =
  var arr = newSeq[string]()
  var args = newSeq[NimNode]()
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
      args.add e
      arr.add("${" & e.strVal & "}")
    else:
      arr.add($e)
  let exp = newStrLitNode(arr.join("") & "$.")
  let ide = ident("scanf")
  result = newNimNode(nnkCall, ide)
  result.add ide
  result.add input
  result.add exp
  for a in args.items:
    result.add a
  # result = newCall(ident("scanf"),input,exp )

proc parse*(ipt: string; ): DateTime {.exportc, discardable, noinit.} =
  echo ipt
  let input = unicode.strip(ipt).toLower
  var year,year2, month, monthdigit, weekday, hour, minute, second, day: int = 0
  var tt: string
  var tz: string
  var tzv = local()
  if pattern(input, year, "-", monthdigit, "-", day): discard #"2013-01-03"

  elif pattern(input, weekday, ",", [], month, [], day, ",", [], year, [],
      hour, ":", minute, [], tt): discard #"Monday, November 25, 2019 11:22 am"

  elif pattern(input, weekday, ",", [], month, [], day, ",", [],
      year): discard #"Monday, November 25, 2019"

  elif pattern(input, month, ".", [], day, [], year, [], "@", [], hour, ":",
      minute, tt): discard #"Nov. 8 2019 @ 3:32am"

  elif pattern(input, day, "-", month, "-", year2): discard # "31-May-19"

  elif pattern(input, month, [], day, ",", [], year, [], "/", [], hour, ":",
      minute, [], tt): discard # "JUNE 12, 2019 / 11:31 AM"

  elif pattern(input, month, [], day, ",", [], year): discard # "JUNE 12, 2019"

  elif pattern(input, day, [], month, ",", [], year, [], hour, ":",
      minute): discard # "07 Nov, 2019 12:44"

  elif pattern(input, month, [], day, ",", [], year, [], "at", [], hour,
      ":", minute, [], tt): discard # "November 20, 2019 at 01:12 PM"

  elif pattern(input, day, [], month, [], year, [], "at", [], hour, ":",
      minute): discard # "13 AUG 2019 AT 15:54"

  elif pattern(input, monthdigit, "/", day, "/", year2, [], hour,
      ":", minute): discard #"7/25/19 13:00"

  elif pattern(input, day, "/", monthdigit, "/", year, [], "-", [], hour,
      ":", minute): discard #"27/08/2019 - 13:54"

  elif pattern(input, day, "/", monthdigit, "/", year2): discard #"9/11/19"

  elif pattern(input, monthdigit, "/", day, "/", year): discard #"03/17/2019"

  elif pattern(input, weekday, [], hour, ":", minute, [], tt, ",", [],
      month, [], day, ",", [], year): discard # "Tue 12:58 PM, Jul 16, 2019"

  elif pattern(input, hour, ":", minute, ",", [], weekday, ",", [], month,
      [], day, ",", [], year): discard

  elif pattern(input, year, "年", monthdigit, "月", day, "日", [
    ], hour, ":", minute): discard # "2019年11月13日 11:00"

  elif pattern(input, month, [], day, ",", [], year, [], "|", [], hour,
      ":", minute, [], tt): discard # "NOV 26, 2019 | 10:00 AM"

  elif pattern(input, month, ".", [], day, ",", [], year, [], "/", [],
      hour, ":", minute, [], tt): discard # "AUG. 12, 2019 / 1:36 PM"

  elif pattern(input, month, [], day, ",", [], year, [], [], hour, ":",
      minute, [], tt): discard # "April 2, 2019 5:18 PM"

  elif pattern(input, month, ".", [], day, ",", [], year): discard # "Nov. 26, 2019"

  elif pattern(input, year, ".", monthdigit, ".", day, [], hour, ":",
      minute, []): discard # "2019.11.26 07:15"

  elif pattern(input, month, [], day, ",", [], year, [], "/", [], hour,
      ":", minute, [], tt, [], tz): discard # "Nov 8, 2019 / 05:22 PM CST"

  elif pattern(input, month, [], day, ",", [], year, ",", [], hour, ":",
      minute, [], tt): discard # "Nov 21, 2019, 1:34 AM"

  elif pattern(input, hour, ":", minute, [], tt, [], tz, [], month, [],
      day, ",", [], year): discard # "12:28 PM EST November 16, 2017"

  elif pattern(input, weekday, ",", [], month, [], day, "st", [],
      year): discard # "Wednesday, August 21st 2019"

  if tt == "pm" and hour < 12:
    hour.inc 12
  if tz.len > 0:
    tzv = timezones.tz(tz)
  var finalMonth = (if month != 0: month else: monthdigit)
  var finalYear = (if year != 0: year else: year2)

  result = initDateTime(day, (times.Month)finalMonth, finalYear, hour, minute, second, tzv)


when defined(nodejs):
  {.emit: "module.exports = parse".}
