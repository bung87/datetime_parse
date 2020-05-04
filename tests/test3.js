const {parse,makeNimstrLit} = require("../build/datetime_parse")
const fs = require('fs');
const path = require('path');
const readline = require('readline');
// console.log(parse("Monday, November 25, 2019 11:22 am"))
const rl = readline.createInterface({
  input: fs.createReadStream(path.join(__dirname,"corpus.txt"),{encoding: "utf8"}),
  crlfDelay: Infinity
});

rl.on('line', (line) => {
  console.log(`Line from file: ${line}`);
  let r = parse(makeNimstrLit(line.trim()) )
  console.log(r)
});