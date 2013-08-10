local _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Two    = require("../lib/tally_ho").Tally_Ho.new()
;

One:on('before hello', function (f)
  f.data.hello.push('before hello')
  f.finish()
end)

One:on('hello', function (f)
  f.data.hello.push('hello')
  f.finish()
end)

One:on('goodbye', function (f)
  f.data.hello.push('goodbye')
  f.finish()
end)

describe( '.detour', function ()

  it( 'finishes parent', function ()
    local o = {hello={}};
    One:run('hello', o, function (f)
      f.detour('goodbye', function (f)
        f.data.hello.push("last goodbye")
      end)
    end)

    assert.same(o, {hello={'before hello', 'hello', 'goodbye', 'last goodbye'}})
  end)

  it( 'includes data of parent', function ()
    local o = {hello={}};
    One:run('hello', o, function (f)
      f.detour('goodbye', function (f)
        f.data.hello.push("last goodbye")
      end)
    end)

    assert.same(o, {hello={'before hello', 'hello', 'goodbye', 'last goodbye'}})
  end)

end) -- === end desc
