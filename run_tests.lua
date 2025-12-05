package.path = "?.lua;?/init.lua;tests/?.lua;tests/?/init.lua;" .. package.path

require("spec_helper")

local test = require("minitest")

_G.describe      = test.describe
_G.it            = test.it
_G.assert_true   = test.assert_true
_G.assert_false  = test.assert_false
_G.assert_equal  = test.assert_equal

require("test_2d")
require("test_3d")

test.run()