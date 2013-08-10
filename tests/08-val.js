
var _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
;

describe( 'val', function () {

  it( 'does not get updated with .finish()', function () {
    var v = 0;

    One.on('one', function (o) { o.finish(1); });
    One.on('after one', function (o) { o.finish(); });

    One.run('one', function (o) { v = o.val; });

    assert.equal(v, 1);
  });

}); // === end desc
