
local Jam = require("jam_bo_ree")
local _   = require("underscore")

local T = Jam.new()

T:on('add', function (o)
  _.push(o.data.result, 1)
end)

T:on('add', function (o)
  _.push(o.data.result, 2)
end)

T:on('mult', 'div', function (o)
  _.push(o.data.result, "mult or div")
end)


-- .RUN ------------------------------------------------
describe( '.run', function ()

  it("runs funcs in order added", function ()
    local j = Jam.new()
    local o = {}
    j:on( 'add', function () _.push(o, 1) end)
    j:on( 'add', function () _.push(o, 2) end)
    j:on( 'add', function () _.push(o, 3) end)
    j:run('add')
    assert.same(o, {1,2,3})
  end)

  it( 'runs on multi-defined events', function ()
    T:run('mult', {result={}}, function (o)
      assert.same( o.data.result, {"mult or div"})
    end)

    T:run('div', {result={}}, function (o)
      assert.same( o.data.result, {"mult or div"})
    end)
  end)

  it( 'combines data objects into one object', function ()
    local a = Jam.new()
    local o = {};
    a:on('one', function (d)
      _.extend(o, d.data, {two='b'})
    end)

    a:on('one', function (d)
      _.extend(o, d.data, {three='c'})
    end)

    a:run('one', {zero = 0}, {one = 1})

    assert.same(o, {zero=0, one=1, two='b', three='c'})
  end)

  it( 'squeezes spaces in event names upon .on and .run', function ()
    T:on('spaced    NAME', function (f)
      f.data.vals = 1
    end)

    local o = {vals=nil}
    T:run('spaced          NAME', o)
    assert.same(o, {vals=1})
  end)

  it( 'ignores capitalization of event name upon .on and .run', function ()
    local j = Jam.new()
    j:on('strange CAPS', function (f)
      f.data.vals.push(1)
    end)

    local o = {vals={}}
    j:run('STRANGE CApS', o)

    assert.same(o, {vals={1}})
  end)

  it( 'ignores surrounding spaces of event name upon .on and .run', function ()
    local j = Jam.new()
    j:on('  non-trim NAME  ', function (f)
      f.data.vals.push(1)
    end)

    local o = {vals={}}
    j:run('non-trim   NAME', o)

    assert.same(o, {vals={1}})
  end)

  it( 'passes last value as second argument to callbacks', function ()
    local last = null;
    local j = Jam.new()
    j:on('a', function (f) return 1 end)
    j:on('a', function (f, l) last = l;  end)
    j:run('a')

    assert.equal(last, 1)
  end)

end) --  === end desc



describe( '.run .includes', function ()

  it( 'prepends arguments in specified order to .includes', function ()
    local t1 = Jam.new()
    t1._val = 1;

    local t2 = Jam.new()
    t2._val = 2;

    local t3 = Jam.new(t1, t2)
    assert.equal(t3.includes[1]._val, t1._val)
    assert.equal(t3.includes[2]._val, t2._val)
  end)

  it( 'filters out duplicates among arguments in .includes', function ()
    local t1 = Jam.new()
    local t2 = Jam.new(t1, t1, t1)
    assert.equal(t2.includes.length, 2)
  end)

  it( 'runs events in .includes', function ()
    local t1 = Jam.new()
    t1:on('one', function (f) _.push(f.data.vals, 1) end)
    t1:on('two', function (f) _.push(f.data.valsm 2) end)

    local t2 = Jam.new(t1, t1, t1)
    t2:on('one', function (f) _.push(f.data.vals, 3) end)
    t2:on('two', function (f) _.push(f.data.vals, 4) end)

    local o = {vals={}};
    t2:run('one', 'two', o)
    assert.same(o, {vals={1,3,2,4}})
  end)

  it( 'runs events in .includes of the .includes', function ()
    local t1 = Jam.new()
    t1:on('add', function (f) _.push(f.data.vals, 1) end)

    local t2 = Jam.new(t1)
    t2:on('add', function (f) _.push(f.data.vals, 2) end)

    local t3 = Jam.new(t2)
    t3:on('add', function (f) _.push(f.data.vals, 3) end)

    local t4 = Jam.new(t3)
    t4:on('add', function (f) _.push(f.data.vals, 4) end)

    local o = {vals={}};
    t4:run('add', o)
    assert.same(o, {vals={1,2,3,4}})
  end)
end) --  === end desc







