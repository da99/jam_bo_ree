
local _      = require("underscore")._
  , assert = require("assert")
  , First  = require("../lib/tally_ho").Tally_Ho.new()
  , Sec    = require("../lib/tally_ho").Tally_Ho.new()
;


First:on('add', function (o)
  o.data.result.push('add')
  First:run(o, 'sub', o.data)
end)

First:on('sub', function (o)
  o.data.result.push('sub')
  Sec:run(o, 'multi', o.data)
end)

Sec:on('multi', function (o)
  o.data.result.push('multi')
  Sec:run(o, 'div', o.data)
end)

Sec:on('div', function (o)
  o.data.result.push('div')
end)

describe( 'parent', function ()

  it( 'runs last callback after nested children are finished', function ()
      local o = {result={}};
      First:run('add', o, function ()
        assert.same(o.result, {'add', 'sub', 'multi', 'div'})
      end)
  end)

end) -- === end desc
