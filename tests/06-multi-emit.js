
var _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Two    = require("../lib/tally_ho").Tally_Ho.new()
  , Third  = require("../lib/tally_ho").Tally_Ho.new()
;

One.on('one', function (o) {
  o.data.l.push(1);
  o.finish();
});

One.on('two', function (o) {
  o.data.l.push(2);
  o.finish();
});

One.on('after two', function (o) {
  o.data.l.push(3);
  o.finish();
});

describe( 'multi run', function () {

  it( 'runs functions in sequential order', function () {
    var o = {l : []};
    One.run('one', 'two', o);
    assert.deepEqual(o.l, [1,2,3]);
  });

  it( 'runs last callback at end', function () {
    var o = {l : []};
    One.run('one', 'two', o, function (o) {
      o.data.l.push('4')
      o.finish();
    });

    assert.deepEqual(o.l, [1,2,3,'4']);
  });

}); // === end desc
