
local _      = require("underscore")._
  , assert = require("assert")
  , TH     = require("../lib/tally_ho").Tally_Ho.new()
;

TH:on('before add', function (o)
  o.data.result.push(1)
end)

TH:on('before add', function (o)
  o.data.result.push(2)
end)

TH:on('add', function (o)
  o.data.result.push(3)
end)

TH:on('after add', function (o)
  o.data.result.push(4)
end)

TH:on('after add', function (o)
  o.data.result.push(5)
end)


describe( 'hooks', function ()

  it( 'runs hooks in defined order', function ()
      TH:run('add', {result={}}, function (o)
        assert.same( o.data.result, {1,2,3,4,5})
      end)
  end)

end) -- === end desc
