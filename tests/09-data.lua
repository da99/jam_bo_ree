
local _   = require("underscore")
local Jam = require("jam_bo_ree")
local One = Jam.new()


describe( 'data', function ()

  it( 'holds changes done in callbacks', function ()
    One:on('change', function (f)
      f.a = 1
    end)

    local data = {}
    One:run('change', data)

    assert.equal(data.a, 1)
  end)

  it( 'merges changes done in callbacks', function ()
    One:on('merge', function (f)
      f.b = 2
    end)

    local data = {}
    One:run('merge', data)

    assert.equal(data.b, 2)
  end)

  it( 'merges multiple objects into the first', function ()
    One:on('multi-merge', function (f)
      f.c = 3
    end)

    local d1 = {}
    local d2 = {d=4}
    One:run('multi-merge', d1, d2)

    assert.same(d1, {c=3, d=4})
  end)

end) -- === end desc
