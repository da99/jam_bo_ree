
if os.getenv('IS_DEV')
  require 'pl.strict'

local setmetatable = setmetatable
local print        = print

local stringx      = require 'pl.stringx'
local sip          = require 'pl.sip'
local pl_utils     = require 'pl.utils'
local _            = require 'underscore'

local M     = {}
local meta  = {}

local WHITE = "%s+";

-- ================================================================
-- ================== Helpers =====================================
-- ================================================================
local function canon_name(str)
  return string.gsub(stringx.strip(string.upper(str)), WHITE, " ")
end


-- -----------------------------------------
-- Clear globals. --------------------------
-- -----------------------------------------
setfenv(1, {})
-- -----------------------------------------


-- ================================================================
-- ================== Jam Bo Ree ==================================
-- ================================================================
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
  end,

  list = function (self, raw_name, create_if_needed)
    local o = self;
    local name = canon_name(raw_name);
    if (not o.funcs[name]) and create_if_needed then
      o.funcs[name] = {};
    end

    return o.funcs[name] || [];
  end,

  entire_list_for = function (self, name)
    local arr = {
      self:list_with_includes('before ' + name),
      self:list_with_includes(name),
      self:list_with_includes('after '  + name)
    }

    return _.flatten(arr);
  end,

  list_with_includes = function (self, raw_name)
    local me  = self;
    local arr = {};
    _.push(arr, _.map(me.includes, function (t)
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
      throw new Error("Error handlers not found for: " + args[1])
    end

    return self:run(unpack(args))
  end,


  on = function (self, ...)
    local args = {...}
    local func = _.pop(args)
    _.each(args, function (name)
      _.push(self:list(name, true), func);
    end);

    return me;
  end,

  run = function (self, ...)

    local args = {...}

    local funcs  = _.select(args, function (u)
      return _.isString(u) or _.isFunction(u)
    end)

    local str_funcs = _.select(funcs, function (u)
      return _.isString(u)
    end);

    local parent = _.detect(args, function (u)
      return u && u.is_task_env
    end);

    local non_data = _.flatten({funcs, parent});

    -- === grab and merge data objects ===
    local data = nil

    _.each(args, function (u)
      if (_.isObject(u) && _.indexOf(non_data, u) < 1 && !u.is_task_env) then
        if not data then
          data = u
        else
          _.extend(data, u)
        end
      end
    end);

    --[[
      // if non string names, only funcs:
      // Example:
      //    .run(parent, {}, func1, func2);
      //    .run(parent,     func1, func2);
      //
    ]]--
    if (str_funcs.length === 0) then
      local t    = M.new()
      local name = 'one-off'
      _.each(funcs, function (f)
        t:on(name, f);
      end);

      return t:run(unpack(_.compact({parent, name, data})));
    end -- ==== if

    Run.new(self, parent, (data || {}), funcs):run()

    return self
  end -- .run -----------------------


}

function M.new(...)
  local new = {}
  setmetatable(new, {__index = meta});
  new.events = {};
  new.includes = {new};

  local args = {...}

  if (#args > 0) then
    _.each(_.flatten(_.reverse(args), function (v)
      _.unshift(t.includes, v)
    end))

    t.includes = _.uniq(t.includes)
  end

  return new
end


-- ================================================================
-- ================== Run (private) ===============================
-- ================================================================
local Run = {}

function Run.do_next(self, ...)

  local args = {...}
  if (#args == 1)
    self.val = args[1];

  self.last = args[1];

  local _next  = _.shift(me.tasks)

  if _next then
    _next(Task_Env.new(self), self.last);
  else

    self.is_done = true

    if self.parent then
      return self.parent:finish(last)
    end

  end

  return me;
end


function Run.run(self)

  if (self.tasks) then
    throw new Error("Already running.");
  end

  self.tasks = {}
  if (!self.parent) then
    _.push( self.tasks, self.tally:list('parent run') )
  end

  _.each(self.proc_list, function (name)
    if (_.isFunction(name)) then
      return _.push(self.tasks, name);
    end

    _.push(self.tasks, self.tally:entire_list_for(name));

  end)

  self.tasks = _.flatten(self.tasks);

  self:do_next();
  return
end


function Run.new(tally, parent, init_data, arr)

  local r     = {
    tally  = tally,
    parent = parent
    data   = init_data
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


-- ================================================================
-- ================== Task_Env (private) ==========================
-- ================================================================

local Task_Env = {}

Task_Env.new = function (run)
  local t  = {}
  setmetatable(t, {__index = Task_Env})

  t.run         = run
  t.data        = run.data
  t.last        = run.last
  t.val         = run.val
  t.is_task_env = true

  return t
end

function Task_Env.finish (self, ...)

  local args        = {...}
  local name_or_val = select(1, ...)
  local err         = select(2, err)

  if (self.is_done || self.run.is_done) then
    throw new Error(".finish called more than once.")
  end

  self.is_done = true

  -- if .finish(name, err);
  if (#args > 1) then -- error
    if (self.run.parent) then
      return self.run.parent:finish(name_or_val, err)
    else
      return self.run.tally:run_error(name_or_val, self.data, {error: err})
    end
  end

  return self.run:do_next(unpack(args))
end

function Task_Env.detour (self, ...)
  local args = {...}
  _.unshift( args, self )
  _.unshift( args, self.data )

  return self.run.tally:run(unpack(args));
end






-- ====================================================
M.canon_name = canon_name;
return M
-- ====================================================




