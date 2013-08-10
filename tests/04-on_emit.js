
var _      = require("underscore")._
  , assert = require("assert")
  , TH     = require("../lib/tally_ho").Tally_Ho.new()
  , H      = require("../lib/tally_ho").Tally_Ho.new()
  , Third  = require("../lib/tally_ho").Tally_Ho.new()
;

TH.on('parent run', function (o) {
  o.data.result.push('parent run');
  o.finish();
});

TH.on('add', function (o) {
  o.data.result.push('add');
  H.run(o, 'sub', o.data);
});

H.on('sub', function (o) {
  o.data.result.push('sub');
  H.run(o, 'div', o.data);
});

H.on('div', function (o) {
  o.data.result.push('div');
  o.finish();
});

describe( 'parent run', function () {

  it( 'runs function only once', function (done) {
    process.nextTick(function () {
      var o = {result: []};
      TH.run('add', o, function () {
        assert.deepEqual(o.result, ['parent run', 'add', 'sub', 'div']);
        done();
      });
    });
  });

}); // === end desc
