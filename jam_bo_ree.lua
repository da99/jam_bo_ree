
local setmetatable = setmetatable
local stringx = require 'pl.stringx'

local print = print
local M    = {}
local meta = {}
local function canon_name(str)
  local trim = stringx.strip(string.upper(str))
  return string.gsub(trim, "%s+", " ");
end


-- -----------------------------------------
-- Clear globals. --------------------------
-- -----------------------------------------
setfenv(1, {})
-- -----------------------------------------


meta = {
  on     = function (self, raw_name, func)
    local name = canon_name(raw_name)
    if not self.events[name] then
      self.events[name] = {}
    end
    local list = self.events[name]
    list[#list+1] = func
    return self
  end
}

function M.new()
  local new = {}
  setmetatable(new, {__index = meta});
  new.events = {};
  return new
end

return M


