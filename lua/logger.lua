--- defines logging module
-- @module logger
local M = {}

local last_log = {
  message = "",
  log_level = 0,
  count = 1,
}

local highlights = {
  source = "Comment",
  count = "Folded",
  log_levels = {
    [vim.log.levels.DEBUG] = 'Debug',
    [vim.log.levels.ERROR] = 'DiagnosticFloatingError',
    [vim.log.levels.INFO] = 'DiagnosticFloatingInfo',
    [vim.log.levels.TRACE] = 'DiagnosticFloatingHint',
    [vim.log.levels.WARN] = 'DiagnosticFloatingWarn',
    [vim.log.levels.OFF] = 'Comment',
  }
}


local get_caller_src = function(stack_level_offset)
  local dbg_info = debug.getinfo(4 + stack_level_offset, "Sl")
  local dbg_src_arr = vim.split(dbg_info.short_src, '/')
  return dbg_src_arr[#dbg_src_arr] .. ':' .. dbg_info.currentline
end

local sanitize_value = function(val)
  if type(val) ~= 'string' then
    val = vim.inspect(val)
  end
  return val
end

process = function(val, opts)
  val = sanitize_value(val)

  -- repeat log counting
  if last_log.message == val and opts.log_level == last_log.log_level then
    last_log.count = last_log.count + 1
  else
    last_log.count = 1
    last_log.message = val
    last_log.log_level = opts.log_level
  end

  local src = get_caller_src(opts.stack_level_offset or 0)
  local count = last_log.count > 1 and '×' .. last_log.count or ''

  vim.api.nvim_echo({
    { count, highlights.count },
    { ' ', '' },
    { src, highlights.source },
    { ' ', '' },
    { val, highlights.log_levels[opts.log_level] },
  }, true, {})
end

M.log = {
  dbg   = function(val, opts) process(val, vim.tbl_deep_extend('force', opts or {}, { log_level = vim.log.levels.DEBUG })) end,
  err   = function(val, opts) process(val, vim.tbl_deep_extend('force', opts or {}, { log_level = vim.log.levels.ERROR })) end,
  info  = function(val, opts) process(val, vim.tbl_deep_extend('force', opts or {}, { log_level = vim.log.levels.INFO })) end,
  trace = function(val, opts) process(val, vim.tbl_deep_extend('force', opts or {}, { log_level = vim.log.levels.TRACE })) end,
  warn  = function(val, opts) process(val, vim.tbl_deep_extend('force', opts or {}, { log_level = vim.log.levels.WARN })) end,
  off   = function(val, opts) process(val, vim.tbl_deep_extend('force', opts or {}, { log_level = vim.log.levels.OFF })) end,
}

setmetatable(M.log, {
  __call = function(self, val, opts)
    self.info(val, { stack_level_offset = 1 })
  end
})

return M
