
var _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
;

describe( 'data', function () {

  it( 'holds changes done in callbacks', function () {
    One.on('change', function (f) {
      f.data.a = 1;
      f.finish();
    });

    var data = {};
    One.run('change', data);

    assert.equal(data.a, 1);
  });

  it( 'merges changes done in callbacks', function () {
    One.on('merge', function (f) {
      f.data.b = 2;
      f.finish();
    });

    var data = {};
    One.run('merge', data);

    assert.equal(data.b, 2);
  });

  it( 'merges multiple objects into the first', function () {
    One.on('multi-merge', function (f) {
      f.data.c = 3;
      f.finish();
    });

    var d1 = {}, d2 = {d: 4};
    One.run('multi-merge', d1, d2);

    assert.deepEqual(d1, {c: 3, d:4});
  });

}); // === end desc
