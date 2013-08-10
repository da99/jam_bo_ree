
var _      = require("underscore")._
  , assert = require("assert")
  , TH     = require("../lib/tally_ho").Tally_Ho.new()
;

TH.on('before add', function (o) {
  o.data.result.push(1);
  o.finish();
});

TH.on('before add', function (o) {
  o.data.result.push(2);
  o.finish();
});

TH.on('add', function (o) {
  o.data.result.push(3);
  o.finish();
});

TH.on('after add', function (o) {
  o.data.result.push(4);
  o.finish();
});

TH.on('after add', function (o) {
  o.data.result.push(5);
  o.finish();
});


describe( 'hooks', function () {

  it( 'runs hooks in defined order', function (done) {
    process.nextTick(function () {
      TH.run('add', {result: []}, function (o) {
        assert.deepEqual( o.data.result, [1,2,3,4,5]);
        done();
      })
    });
  });

}); // === end desc
