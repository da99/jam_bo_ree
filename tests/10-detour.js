var _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Two    = require("../lib/tally_ho").Tally_Ho.new()
;

One.on('before hello', function (f) {
  f.data.hello.push('before hello');
  f.finish();
});

One.on('hello', function (f) {
  f.data.hello.push('hello');
  f.finish();
});

One.on('goodbye', function (f) {
  f.data.hello.push('goodbye');
  f.finish();
});

describe( '.detour', function () {

  it( 'finishes parent', function () {
    var o = {hello: []};
    One.run('hello', o, function (f) {
      f.detour('goodbye', function (f) {
        f.data.hello.push("last goodbye");
      });
    });

    assert.deepEqual(o, {hello: ['before hello', 'hello', 'goodbye', 'last goodbye']});
  });

  it( 'includes data of parent', function () {
    var o = {hello: []};
    One.run('hello', o, function (f) {
      f.detour('goodbye', function (f) {
        f.data.hello.push("last goodbye");
      });
    });

    assert.deepEqual(o, {hello: ['before hello', 'hello', 'goodbye', 'last goodbye']});
  });

}); // === end desc
