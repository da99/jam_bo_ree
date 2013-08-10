
if os.getenv('IS_DEV')
  require 'pl.strict'

local setmetatable = setmetatable
local print        = print

local stringx      = require 'pl.stringx'
local pl_utils     = require 'pl.utils'
local _            = require 'underscore'

local M     = {}
local meta  = {}

local function canon_name(str)
  local trim = stringx.strip(string.upper(str))
  return string.gsub(trim, "%s+", " ")
end


-- -----------------------------------------
-- Clear globals. --------------------------
-- -----------------------------------------
setfenv(1, {})
-- -----------------------------------------


meta = {
  on = function (self, raw_name, func)
    local name = canon_name(raw_name)
    if not self.events[name] then
      self.events[name] = {}
    end
    local list = self.events[name]
    list[#list+1] = func
    return self
  end,

  events_for = function (self, raw_name)
    name = canon_name(raw_name)
    return self.events[name];
  end,

  run = function (self, ...)
    -- get all funcs we need
    local funcs = _.map({...}, function (v)
      if pl_utils.is_type(v, 'string') then
        return self:events_for(v)
      else -- let's assume it's a func
        return v
      end
    end)

    _.each(_.flatten(funcs), function (f)
      f();
    end);

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




