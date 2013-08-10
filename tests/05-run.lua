
local _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Two    = require("../lib/tally_ho").Tally_Ho.new()
  , Third  = require("../lib/tally_ho").Tally_Ho.new()

describe( 'run', function ()

  it( 'runs functions in sequential order', function ()
    local d = {};
    One:run(
      function (o) d.push(1) end,
      function (o) d.push(2) end
    )
    assert.same(d, {1,2})
  end)

  it( 'finishes parent when functions are done', function ()
    local d = {};

    One:on('finishes parent', function (o)
      d.push(1)
      Two:run(
        o,
        function (o) d.push(2) end,
        function (o) d.push(3) end
     )
   end)

    One:run('finishes parent')

    assert.same(d, {1,2,3})
  end)

end) -- === end desc
