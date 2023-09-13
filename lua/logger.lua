local M = {}

local last_log = {
  message = "",
  log_level = 0,
  count = 1,
}

local get_caller_src = function(stack_level_offset)
  local dbg_info = debug.getinfo(4 + stack_level_offset, "Sl")
  local dbg_src_arr = vim.split(dbg_info.short_src, '/')
  return dbg_src_arr[#dbg_src_arr] .. ':' .. dbg_info.currentline
end

local sanitize_value = function(val)
  if type(val) == 'string' then
    return val
  else
    return vim.inspect(val)
  end
end

local process = function(val, opts)
  val = sanitize_value(val)
  local src = get_caller_src(opts.stack_level_offset or 0)

  -- repeat log counting
  if last_log.message == val and opts.log_level == last_log.log_level then
    last_log.count = last_log.count + 1
  else
    last_log.count = 1
    last_log.message = val
    last_log.log_level = opts.log_level
  end

  local count = last_log.count > 1 and '×' .. last_log.count or '  '

  vim.schedule(function()
    vim.notify(val, opts.log_level, { title = count .. ' ' .. src })
  end)
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
    ---@diagnostic disable-next-line: redefined-local
    local opts = opts or {}
    opts.stack_level_offset = (opts.stack_level_offset or 0) + 1
    self.info(val, opts)
  end
})

return M
