
local _   = require"underscore"
local stringx = require"pl.stringx"
local Jam = require"jam_bo_ree"
local One = Jam.new()
local Ho  = Jam.new()

One:on_error('not_found', function (o, err)
  _.push(o.result, err)
end)

One:on('raise not_found', function (o)
  return 'not_found', 1
end)

One:on('raise made up error', function (o)
  return 'made up error', "rand val"
end)

describe( 'error handling', function ()

  it( 'runs error handler', function ()
    local o = {result={}};
    One:run('raise not_found', o)
    assert.same( {result={1}}, o )
  end)

  it( 'raises error if no error handlers found', function ()
    local err = null;
    local a, b = pcall(One.run, One, 'raise made up error')
    local pieces = _.split(b, ':')
    _.shift(pieces)
    _.shift(pieces)
    local msg = stringx.strip(_.join(pieces, ':'))

    assert.same(false, a)
    assert.same("No error handler found for: MADE UP ERROR: rand val", msg)
  end)

end) -- === end desc
