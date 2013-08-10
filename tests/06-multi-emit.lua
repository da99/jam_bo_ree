
local _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Two    = require("../lib/tally_ho").Tally_Ho.new()
  , Third  = require("../lib/tally_ho").Tally_Ho.new()
;

One:on('one', function (o)
  o.data.l.push(1)
  o.finish()
end)

One:on('two', function (o)
  o.data.l.push(2)
  o.finish()
end)

One:on('after two', function (o)
  o.data.l.push(3)
  o.finish()
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
      o.data.l.push('4')
      o.finish()
    end)

    assert.same(o.l, {1,2,3,'4'})
  end)

end) -- === end desc
