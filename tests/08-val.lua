
local _   = require("underscore")
local Jam = require "jam_bo_ree"
local One = Jam.new()

describe( 'val', function ()

  it( 'does not get updated with .finish()', function ()
    local v = 0;

    One:on('one', function (o) return 1 end)
    One:on('after one', function (o) return end)

    One:run('one', function (o) v = o.val end)

    assert.equal(v, 1)
  end)

end) -- === end desc
