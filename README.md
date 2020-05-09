# datetime_parse  [![Npm Version](https://badgen.net/npm/v/datetime_parse)](https://www.npmjs.com/package/datetime_parse)  ![npm: total downloads](https://badgen.net/npm/dt/datetime_parse) 

a datetime parser write in [Nim](https://nim-lang.org/)  

parse datetime from various media resources  

this lib using pattern match design to parse datetime from various media resources  

supported format see [corpus.txt](./tests/corpus.txt)  

this repo also demonstrate how to write a nim module and export it as nodejs module.  
## Installation  
for nim  

`nimble install datetime_parse`  

for js 

`npm install datetime_parse` or   
`yarn add datetime_parse`

## Usage  
for js  

``` js
const {parse}  = require("datetime_parse")
const assert = require('assert');
const s ="Monday, November 25, 2019 11:22 am"
let r = parse(s)
assert.equal(r.getFullYear(),2019)
```  
for nim  

``` Nim
import datetime_parse
const s ="Monday, November 25, 2019 11:22 am"
let r = parse(s)
assert r.year == 2019 
```
## Development  

build  

`nimble buildjs`

## Deployment  

dist    

`nimble distjs`

## Contribution  

add a datetime format welcome.

## test  

`nimble tests`