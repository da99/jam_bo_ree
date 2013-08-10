
local Jam = require("jam_bo_ree")

describe(".new", function ()
  it("sets events to an empty table", function ()
    assert.equals(0, #Jam.new().events);
  end);
end);


describe(".on", function ()
  it("adds func to .events", function ()
    local j = Jam.new()
    local f1 = function () end
    local f2 = function () end
    j:on("add", f1);
    j:on("add", f2);

    assert.equal(f1, j.events.ADD[1]);
    assert.equal(f2, j.events.ADD[2]);
  end);
end);
