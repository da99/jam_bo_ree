
var _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Ho     = require("../lib/tally_ho").Tally_Ho.new()
;

One.on('not_found', function (o, err) {
  o.data.result.push(err);
});

One.on('subtract', function (o) {
  o.finish('not_found', 1);
});

One.on('raise nested err', function (o) {
  Ho.run(o, 'nested', {});
});

One.on('error not found', function (o) {
  o.finish('made up error', 1);
});

Ho.on('nested', function (o) {
  o.finish('not_found', 2);
});

describe( 'error handling', function () {

  it( 'runs error handler', function () {
    var o = {result: []};
    One.run('subtract', o);
    assert.deepEqual( o.error, 1);
  });

  it( 'catches errors bubbled up from nested flows', function () {
    var o = {result: []};
    One.run('raise nested err', o);
    assert.deepEqual( o.error, 2);
  });

  it( 'raises error if no error handlers found', function () {
    var err = null;
    try {
      One.run('error not found');
    } catch(e) {
      err = e;
    }

    assert.equal(err.message, "Error handlers not found for: made up error");
  });
}); // === end desc
