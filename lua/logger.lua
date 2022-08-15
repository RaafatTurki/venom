--- defines logging mechanism.
-- @module logger
local M = {}

M.last_log_msg = ""
M.last_log_msg_log_lvl = 0
M.last_log_msg_count = 0

M.highlights = {
  source = "Comment",
  log_levels = {
    "DebugFG",
    "DiagnosticFloatingError",
    "DiagnosticFloatingInfo",
    "DiagnosticFloatingHint",
    "DiagnosticFloatingWarn",

    -- DEBUG = vim.log.levels.DEBUG,
    -- ERROR = vim.log.levels.ERROR,
    -- INFO = vim.log.levels.INFO,
    -- TRACE = vim.log.levels.TRACE,
    -- WARN = vim.log.levels.WARN,

    -- trace  0
    -- debug  1
    -- info   2
    -- warn   3
    -- error  4
  }
}


local get_caller_src = function(stack_lvl_off)
  local dbg_info = debug.getinfo(4 + stack_lvl_off, "Sl")
  local dbg_src_arr = vim.split(dbg_info.short_src, '/')
  return dbg_src_arr[#dbg_src_arr]..':'.. dbg_info.currentline
end

local sanitize_value = function(val)
  if type(val) ~= 'string' then
    val = vim.inspect(val)
  end
  return val
end

M.process = function(val, opts)
  val = sanitize_value(val)

  -- repeat log counting
  if M.last_log_msg == val and opts.log_lvl == M.last_log_msg_log_lvl then
    M.last_log_msg_count = M.last_log_msg_count + 1
  else
    M.last_log_msg_count = 0
  end

  M.last_log_msg = val
  M.last_log_msg_log_lvl = opts.log_lvl

  local src = get_caller_src(opts.stack_lvl_off or 0)
  local count = M.last_log_msg_count > 0 and ' ×'..M.last_log_msg_count or ''
  local hl = M.highlights.log_levels[opts.log_lvl] 
  -- local msg = src..' '..val..count

  vim.api.nvim_echo({
    { src, M.highlights.source },
    { ' ', '' },
    { val, M.highlights.log_levels[opts.log_lvl] },
  }, true, {})
end

M.log = {
  dbg   = function(val, opts) M.process(val, vim.tbl_deep_extend('force', opts or {}, { log_lvl = 1 })) end,
  err   = function(val, opts) M.process(val, vim.tbl_deep_extend('force', opts or {}, { log_lvl = 2 })) end,
  info  = function(val, opts) M.process(val, vim.tbl_deep_extend('force', opts or {}, { log_lvl = 3 })) end,
  trace = function(val, opts) M.process(val, vim.tbl_deep_extend('force', opts or {}, { log_lvl = 4 })) end,
  warn  = function(val, opts) M.process(val, vim.tbl_deep_extend('force', opts or {}, { log_lvl = 5 })) end,

  -- TODO: replace with proper buffer flushing
  flush = function() vim.api.nvim_echo({ { '\n', '' }, }, false, {}) end
}

setmetatable(M.log, {
  __call = function(self, val, opts)
    self.info(val, { stack_lvl_off = 1 })
  end
})

return M
