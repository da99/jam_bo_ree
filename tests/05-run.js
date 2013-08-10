
var _      = require("underscore")._
  , assert = require("assert")
  , One    = require("../lib/tally_ho").Tally_Ho.new()
  , Two    = require("../lib/tally_ho").Tally_Ho.new()
  , Third  = require("../lib/tally_ho").Tally_Ho.new()
;

describe( 'run', function () {

  it( 'runs functions in sequential order', function () {
    var d = [];
    One.run(
      function (o) { d.push(1); o.finish(); },
      function (o) { d.push(2); o.finish(); }
    );
    assert.deepEqual(d, [1,2]);
  });

  it( 'finishes parent when functions are done', function () {
    var d = [];

    One.on('finishes parent', function (o) {
      d.push(1);
      Two.run(
        o,
        function (o) { d.push(2); o.finish(); },
        function (o) { d.push(3); o.finish(); }
     );
    });

    One.run('finishes parent');

    assert.deepEqual(d, [1,2,3]);
  });

}); // === end desc
