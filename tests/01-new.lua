
local Jam = require("jam_bo_ree")

describe(".new", function ()
  it("sets events to an empty table", function ()
    assert.equals(0, #Jam.new().ons)
  end)
end) -- describe ------------------
