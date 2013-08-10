
local Jam = require("jam_bo_ree")
local _   = require("underscore")

local T = Jam.new()
local F = Jam.new()


T.on('add', function (o)
  _.push(o.data.result, 1)
  o.finish()
end)

T.on('add', function (o)
  _.push(o.data.result, 2)
  o.finish()
end)

T.on('mult', 'div', function (o)
  _.push(o.data.result, o.run.proc_list[0])
  o.finish()
end)


-- .RUN ------------------------------------------------
describe( '.run', function ()

  it("runs funcs in order added", function ()
    local j = Jam.new()
    local o = {}
    j:on('add', function () o[#o+1] = 1 end)
    j:on('add', function () o[#o+1] = 2 end)
    j:on('add', function () o[#o+1] = 3 end)
    j:run('add')
    assert.same(o, {1,2,3})
  end)

  it( 'runs on multi-defined events', function (done)
    process.nextTick(function ()
      T.run('mult', {result: []}, function (o)
        assert.deepEqual( o.data.result, ['mult'])
      end)

      T.run('div', {result: []}, function (o)
        assert.deepEqual( o.data.result, ['div'])
        done()
      end)
    end)
  end)

  it( 'combines data objects into one object', function ()
    var t = F;
    var o = {};
    t.on('one', function (d)
      _.extend(o, d.data, {two: 'b'})
      d.finish()
    end)

    t.on('one', function (d)
      _.extend(o, d.data, {three: 'c'})
      d.finish()
    end)

    t.run('one', {zero: 0}, {one: 1})

    assert.deepEqual(o, {zero: 0, one: 1, two: 'b', three: 'c'})
  end)

  it( 'squeezes spaces in event names upon .on and .run', function ()
    T.on('spaced    NAME', function (f)
      f.data.vals.push(1)
    end)

    var o = {vals: []}
    T.run('spaced          NAME', o)
    assert.deepEqual(o, {vals: [1]})
  end)

  it( 'ignores capitalization of event name upon .on and .run', function ()
    T.on('strange CAPS', function (f)
      f.data.vals.push(1)
    end)

    var o = {vals: []}
    T.run('STRANGE CApS', o)
    assert.deepEqual(o, {vals: [1]})
  end)

  it( 'ignores surrounding spaces of event name upon .on and .run', function ()
    T.on('  non-trim NAME  ', function (f)
      f.data.vals.push(1)
    end)

    var o = {vals: []}
    T.run('non-trim   NAME', o)
    assert.deepEqual(o, {vals: [1]})
  end)

  it( 'passes last value as second argument to callbacks', function ()
    var last = null;
    T.on('a', function (f) f.finish(1) end)
    T.on('a', function (f, l) last = l;  end)
    T.run('a')

    assert.equal(last, 1)
  end)

end) --  === end desc



describe( '.run .includes', function ()
  it( 'prepends arguments in specified order to .includes', function ()
    var t1 = Tally_Ho.new()
    t1._val = 1;

    var t2 = Tally_Ho.new()
    t2._val = 2;

    var t3 = Tally_Ho.new(t1, t2)
    assert.equal(t3.includes[0]._val, t1._val)
    assert.equal(t3.includes[1]._val, t2._val)
  end)

  it( 'filters out duplicates among arguments in .includes', function ()
    var t1 = Tally_Ho.new()
    var t2 = Tally_Ho.new(t1, t1, t1)
    assert.equal(t2.includes.length, 2)
  end)

  it( 'runs events in .includes', function ()
    var t1 = Tally_Ho.new()
    t1.on('one', function (f) f.data.vals.push(1) f.finish() end)
    t1.on('two', function (f) f.data.vals.push(2) f.finish() end)

    var t2 = Tally_Ho.new(t1, t1, t1)
    t2.on('one', function (f) f.data.vals.push(3) f.finish() end)
    t2.on('two', function (f) f.data.vals.push(4) f.finish() end)

    var o = {vals: []};
    t2.run('one', 'two', o)
    assert.deepEqual(o, {vals: [1,3,2,4]})
  end)

  it( 'runs events in .includes of the .includes', function ()
    var t1 = Tally_Ho.new()
    t1.on('add', function (f) f.data.vals.push(1) f.finish() end)

    var t2 = Tally_Ho.new(t1)
    t2.on('add', function (f) f.data.vals.push(2) f.finish() end)

    var t3 = Tally_Ho.new(t2)
    t3.on('add', function (f) f.data.vals.push(3) f.finish() end)

    var t4 = Tally_Ho.new(t3)
    t4.on('add', function (f) f.data.vals.push(4) f.finish() end)

    var o = {vals: []};
    t4.run('add', o)
    assert.deepEqual(o, {vals: [1,2,3,4]})
  end)
end) --  === end desc







