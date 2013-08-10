
local _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Two    = require("../lib/tally_ho").Tally_Ho.new()
  , Third  = require("../lib/tally_ho").Tally_Ho.new()

One:on('one', function (o)
  return 1
end)

One:on('two', function (o)
  return 2
end)

One:on('after two', function (o)
  assert.equal(o.last, 2)
  return 3
end)

describe( 'finish', function ()

  it( 'saves last value', function ()

    One:run('one', function (o)
      assert.equal(o.last, 1)
    end)

    One:run('two', function (o)
      assert.equal(o.last, 3)
    end)

  end)

  it( 'throws error if Run is done', function ()
    Two:on('finish run', function (o)
      o.run.is_done = true;
      return 1
    end)

    Two:on('finish run', function (o) return 2 end)

    local err = null

    try {
      Two:run('finish run')
    } catch (e) {
      err = e;
    }

    assert.equal(err.message.indexOf(".finish called more than once"), 0)
  end)

  it( 'throws error if called more than once', function ()
    Two:on('finish 2', function (o)
      return 1
      return 2
    end)

    Two:on('finish 2', function (o) end)

    local err = null

    try {
      Two:run('finish 2')
    } catch (e) {
      err = e;
    }

    assert.equal(err.message.indexOf(".finish called more than once"), 0)
  end)

end) -- === end desc
