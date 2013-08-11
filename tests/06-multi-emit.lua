
local _     = require("underscore")
local Jam   = require "jam_bo_ree"
local One   = Jam.new()
local Two   = Jam.new()
local Third = Jam.new()

One:on('one', function (o)
  _.push(o.l, 1)
end)

One:on('two', function (o)
  _.push(o.l, 2)
end)

One:on('after two', function (o)
  _.push(o.l, 3)
end)

describe( 'multi run', function ()

  it( 'runs functions in sequential order', function ()
    local o = {l={}};
    One:run('one', 'two', o)
    assert.same(o.l, {1,2,3})
  end)

  it( 'runs last callback at end', function ()
    local o = {l={}};
    One:run('one', 'two', o, function (o)
      _.push(o.l, '4')
    end)

    assert.same(o.l, {1,2,3,'4'})
  end)

end) -- === end desc
