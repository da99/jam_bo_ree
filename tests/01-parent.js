
var _      = require("underscore")._
  , assert = require("assert")
  , First  = require("../lib/tally_ho").Tally_Ho.new()
  , Sec    = require("../lib/tally_ho").Tally_Ho.new()
;


First.on('add', function (o) {
  o.data.result.push('add');
  First.run(o, 'sub', o.data);
});

First.on('sub', function (o) {
  o.data.result.push('sub');
  Sec.run(o, 'multi', o.data);
});

Sec.on('multi', function (o) {
  o.data.result.push('multi');
  Sec.run(o, 'div', o.data);
});

Sec.on('div', function (o) {
  o.data.result.push('div');
  o.finish();
});

describe( 'parent', function () {

  it( 'runs last callback after nested children are finished', function (done) {
    process.nextTick(function () {
      var o = {result: []};
      First.run('add', o, function () {
        assert.deepEqual(o.result, ['add', 'sub', 'multi', 'div']);
        done();
      });
    });
  });

}); // === end desc
