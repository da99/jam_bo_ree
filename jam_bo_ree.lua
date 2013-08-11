

local setmetatable = setmetatable
local print        = print
local select       = select

local unpack       = unpack
local stringx      = require 'pl.stringx'
local sip          = require 'pl.sip'
local pl_utils     = require 'pl.utils'
local _            = require 'underscore'

local Jam_Bo_Ree = {is_jam_bo_ree = true}
local Run        = {is_run = true}

local WHITE = "%s+";

-- ================================================================
-- ================== Helpers =====================================
-- ================================================================
local function canon_name(str)
  return (string.gsub(stringx.strip(string.upper(str)), WHITE, " "))
end


-- -----------------------------------------
-- Clear globals. --------------------------
-- -----------------------------------------
setfenv(1, {})

-- -----------------------------------------


-- ================================================================
-- ================== Jam Bo Ree ==================================
-- ================================================================
Jam_Bo_Ree = {
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
  end,

  list = function (self, raw_name, create_if_needed)
    local o = self;
    local name = canon_name(raw_name);
    if (not o.events[name]) and create_if_needed then
      o.events[name] = {};
    end

    return o.events[name] or {}
  end,

  entire_list_for = function (self, name)
    local arr = {
      self:list_with_includes('before ' .. name),
      self:list_with_includes(name),
      self:list_with_includes('after '  .. name)
    }

    return _.flatten(arr);
  end,

  list_with_includes = function (self, raw_name)
    local me  = self;
    local arr = {};
    _.push(arr, _.map(self.includes, function (t)
      if (t == me) then
        return t:list(raw_name)
      else
        return t:list_with_includes(raw_name)
      end
    end));

    return _.flatten(arr);
  end,

  run_error = function (self, ...)
    local args  = {...}
    local tasks = {}
    if (#self:entire_list_for(args[1]) == 0) then
      error("Error handlers not found for: " .. args[1])
    end

    return self:run(unpack(args))
  end,


  on = function (self, ...)
    local args = {...}
    local func = _.pop(args)
    _.each(args, function (name)
      _.push(self:list(name, true), func);
    end);

    return self;
  end,

  run = function (self, ...)

    local args = {...}

    local funcs  = _.select(args, function (u)
      return _.isString(u) or _.isFunction(u)
    end)

    local str_funcs = _.select(funcs, function (u)
      return _.isString(u)
    end);

    local parent_run = _.detect(args, function (u)
      return (_.isObject(u) and u.is_run)
    end);

    local non_data = _.flatten({funcs, parent_run});

    -- === grab and merge data objects ===
    local data = nil

    _.each(args, function (u)
      if (_.isObject(u) and _.indexOf(non_data, u) < 1 and not u.is_run) then
        if not data then
          data = u
        else
          _.extend(data, u)
        end
      end
    end);

    --[[
      // if run is called without any string funcs:
      // Example:
      //    .run(parent_run, {}, func1, func2);
      //    .run(parent_run,     func1, func2);
      //
    ]]--
    if ((not str_funcs) or #str_funcs == 0) then
      local t    = Jam_Bo_Ree.new()
      local name = 'one-off'
      _.each(funcs, function (f)
        t:on(name, f);
      end);

      return t:run(unpack(_.compact({parent_run, name, data})));
    end -- ==== if

    -- === Process final results === --
    local results = {Run.new(self, parent_run, (data or {}), funcs):run()}
    local l       = _.size(results)
    if l  < 2 then
      return results[1]
    end

    -- === Run error if found === --
    local name     = canon_name(results[1])
    local err      = results[2]
    local err_func = self.on_error[name]
    if err_func then
      return err_func(err)
    end
    error("No error handler found for: " .. name .. ": " .. err)
  end -- .run -----------------------


} -- Jam_Bo_Ree ---------------------

function Jam_Bo_Ree.new(...)
  local new = {}
  setmetatable(new, {__index = Jam_Bo_Ree})
  new.events   = {}

  local args = {...}

  -- generate .includes table (array)
  new.includes = _.uniq(_.flatten(args))

  -- include itself in .includes
  _.push(new.includes, new)

  return new
end


-- ================================================================
-- ================== Run (private) ===============================
-- ================================================================

function Run.new(jam_bo_ree, parent_run, data, arr)

  local r = {
    jam_bo_ree = jam_bo_ree,
    parent_run = parent_run,
    data       = data,
    val        = nil
  }

  setmetatable(r, {__index = Run})

  r.proc_list = _.map(arr, function (n)
    if (_.isString(n)) then
      return canon_name(n)
    end

    return n
  end);

  return r;
end


function Run.run(self)

  if (self.tasks) then
    error("Already running.");
  end

  self.tasks = {}

  _.each(self.proc_list, function (name)
    if (_.isFunction(name)) then
      return _.push(self.tasks, name);
    end

    _.push(self.tasks, self.jam_bo_ree:entire_list_for(name));
  end)

  self.tasks = _.flatten(self.tasks);

  _.detect(self.tasks, function (func)
    local args = {func(self.data, self.last)}
    local l    = _.size(args)

    if l == 0 then
      self.last = nil
    elseif l == 1 then
      self.last = args[1]
      self.val  = args[1]
    else
      self.last    = nil
      self.is_stop = true
      self.err     = args[1]
      self.err_msg = args[2]
    end

    return self.is_stop;
  end);

  if (self.err) then
    return self.err, self.err_msg
  else
    return self.val
  end
end



-- ====================================================
Jam_Bo_Ree.canon_name = canon_name;
return Jam_Bo_Ree
-- ====================================================




