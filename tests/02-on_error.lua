
local _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Ho     = require("../lib/tally_ho").Tally_Ho.new()
;

One:on('not_found', function (o, err)
  o.data.result.push(err)
end)

One:on('subtract', function (o)
  o.finish('not_found', 1)
end)

One:on('raise nested err', function (o)
  Ho:run(o, 'nested', {})
end)

One:on('error not found', function (o)
  o.finish('made up error', 1)
end)

Ho:on('nested', function (o)
  o.finish('not_found', 2)
end)

describe( 'error handling', function ()

  it( 'runs error handler', function ()
    local o = {result={}};
    One:run('subtract', o)
    assert.same( o.error, 1)
  end)

  it( 'catches errors bubbled up from nested flows', function ()
    local o = {result={}};
    One:run('raise nested err', o)
    assert.same( o.error, 2)
  end)

  it( 'raises error if no error handlers found', function ()
    local err = null;
    try {
      One:run('error not found')
    } catch(e) {
      err = e;
    }

    assert.equal(err.message, "Error handlers not found for: made up error")
  end)
end) -- === end desc
