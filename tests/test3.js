const parse = require("../dist/datetime_parse")
const fs = require('fs');
const path = require('path');
const readline = require('readline');
console.log(parse("Monday, November 25, 2019 11:22 am"))
const rl = readline.createInterface({
  input: fs.createReadStream(path.join(__dirname,"corpus.txt")),
  crlfDelay: Infinity
});

rl.on('line', (line) => {
  console.log(`Line from file: ${line}`);
  console.log(parse(line.trim()))
});