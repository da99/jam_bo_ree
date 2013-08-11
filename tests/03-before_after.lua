
local _   = require"underscore"
local Jam = require"jam_bo_ree"
local TH  = Jam.new()

TH:on('before add', function (o)
  _.push(o.result, 1)
end)

TH:on('before add', function (o)
  _.push(o.result, 2)
end)

TH:on('add', function (o)
  _.push(o.result, 3)
end)

TH:on('after add', function (o)
  _.push(o.result, 4)
end)

TH:on('after add', function (o)
  _.push(o.result, 5)
end)


describe( 'hooks', function ()

  it( 'runs hooks in defined order', function ()
    local o = {result={}}
    TH:run('add', o)
    assert.same( {1,2,3,4,5}, o.result)
  end)

end) -- === end desc

