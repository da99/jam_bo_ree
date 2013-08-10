
local _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
;

describe( 'val', function ()

  it( 'does not get updated with .finish()', function ()
    local v = 0;

    One:on('one', function (o) o.finish(1) end)
    One:on('after one', function (o) o.finish() end)

    One:run('one', function (o) v = o.val end)

    assert.equal(v, 1)
  end)

end) -- === end desc
