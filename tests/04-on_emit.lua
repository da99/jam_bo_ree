
local _      = require("underscore")._
  , assert = require("assert")
  , TH     = require("../lib/tally_ho").Tally_Ho.new()
  , H      = require("../lib/tally_ho").Tally_Ho.new()
  , Third  = require("../lib/tally_ho").Tally_Ho.new()
;

TH:on('parent run', function (o)
  o.data.result.push('parent run')
  o.finish()
end)

TH:on('add', function (o)
  o.data.result.push('add')
  H:run(o, 'sub', o.data)
end)

H:on('sub', function (o)
  o.data.result.push('sub')
  H:run(o, 'div', o.data)
end)

H:on('div', function (o)
  o.data.result.push('div')
  o.finish()
end)

describe( 'parent run', function ()

  it( 'runs function only once', function ()
      local o = {result={}};
      TH:run('add', o, function ()
        assert.same(o.result, {'parent run', 'add', 'sub', 'div'})
      end)
  end)

end) -- === end desc
