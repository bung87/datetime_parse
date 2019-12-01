import strscans,unicode,macros,sequtils,strutils,sugar
import times except parse,join
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

const Months = collect(newSeq):
  for e in Month.items:
    let lower = ($e).toLower
    # (ord(e),lower.substr(0,2))
    (ord(e),[lower,lower.substr(0,2),lower.substr(0,3)])

proc month(input: string; intVal: var int; start: int; ): int =
  var len = 3
  var i = start + len
  var tmp: string
  var r:Rune
  fastRuneAt(input,i,r)
  for e in Months:
    while i < input.len and isAlpha(r):
      fastRuneAt(input,i,r)
      inc len
    tmp = input.substr(start, start + len - 1)
    if tmp in e[1]:
      result = len(tmp)
      intVal = e[0]
      break

const WeekDays = collect(newSeq):
  for e in WeekDay.items:
    let lower = ($e).toLower
    # (ord(e),lower.substr(0,2))
    (ord(e),[lower,lower.substr(0,2),lower.substr(0,3)])
    
proc weekday(input: string; intVal: var int; start: int; ): int =
  var len = 3
  var i = start + len
  var tmp: string
  var r:Rune
  fastRuneAt(input,i,r)
  for e in WeekDays:
    while i < input.len and isAlpha(r):
      fastRuneAt(input,i,r)
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

macro pattern(x: varargs[untyped]):string =
  var arr = newSeq[string]()
  for e in x.items:
    var tmp:string
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
      # echo e.kind
      arr.add($e)
  result = newStrLitNode(arr.join(""))

proc parse*(input: string): DateTime {.exportc.} =
  let input = input.toLower
  var year, month, weekday, hour, minute, second, day: int
  var tt: string
  # "${ndigits(4)}-${ndigits(2)}-${ndigits(2)}$."
  if scanf(input, pattern(ndigits(4),"-",ndigits(2),"-",ndigits(2)), year,
      month, day):#"2013-01-03"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(weekday,",",[],month,[],ndigits(2),",",[],ndigits(4),[],ndigits(2),":",ndigits(2),[],tt), weekday,
    month, day, year, hour, minute, tt):#"Monday, November 25, 2019 11:22 am"
    if tt == "pm":
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(weekday,",",[],month,[],ndigits(2),",",[],ndigits(4)), weekday,
    month, day, year): #"Monday, November 25, 2019"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(month,".",[],ndigits(2),[],ndigits(4),[],"@",[],ndigits(2),":",ndigits(2),tt), month,
    day, year, hour, minute, tt):#"Nov. 8 2019 @ 3:32am"
    if tt == "pm":
      hour.inc 12
    result = initDateTime(day, (times.Month)month, year, hour, minute, 0, utc())
  elif scanf(input, pattern(ndigits(2),"-",month,ndigits(2)), day,
    month, year): # "31-May-19"
    result = initDateTime(day, (times.Month)month, year, 0, 0, 0, utc())
  elif scanf(input, pattern(month,[],ndigits(2),",",[],ndigits(4),[],"/",[],ndigits(2),":",ndigits(2),tt), month,
    day, year, hour, minute, tt): # "JUNE 12, 2019 / 11:31 AM"
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
  echo parse("11/13/19 9:57")
  echo parse("2019年11月13日 11:00")
  echo parse("NOV 26, 2019 | 10:00 AM")
  echo parse("25-Sep-19")
  echo parse("5-Nov-19")
  echo parse("JULY 9, 2019 AT 8:47 AM")
  echo parse("6-Nov-19")
  echo parse("AUG. 12, 2019 / 1:36 PM")
  echo parse("April 2, 2019 5:18 PM")
  echo parse("Nov. 26, 2019")
  echo parse("2019.11.26 07:15")
  echo parse("SEPT. 18, 2019 / 12:22 PM")
  echo parse("Thursday, Nov 07, 2019 07:10 AM")
  echo parse("Nov 8, 2019 / 05:22 PM CST")
  echo parse("12:28 PM EST November 16, 2017")
