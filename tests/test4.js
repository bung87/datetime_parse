const {parse,makeNimstrLit}  = require("../build/datetime_parse")
const s ="Monday, November 25, 2019 11:22 am"
console.log(parse(makeNimstrLit(s)))