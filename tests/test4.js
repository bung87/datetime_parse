const {parse}  = require("../build/datetime_parse")
const assert = require('assert');
const s ="Monday, November 25, 2019 11:22 am"
let r = parse(s)
assert.equal(r.year,2019)