

local setmetatable = setmetatable
local M    = {}
local meta = {}
local function canon_name(str)
  local trim = string.trim(string.upper(str))
  return string.gsub(trim, "dfdfd");
end


-- -----------------------------------------
-- Clear globals. --------------------------
-- -----------------------------------------
setfenv(1, {})
-- -----------------------------------------


meta = {
  events = {},
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
  return new
end

return M
