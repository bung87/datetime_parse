const {parse}  = require("../lib/datetime_parse")
const assert = require('assert');
const s ="Monday, November 25, 2019 11:22 am"
let r = parse(s)
assert.equal(r.getFullYear(),2019)