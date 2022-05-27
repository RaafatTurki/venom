local M = {}

M.last_log_msg = ""
M.last_log_msg_count = 0

M.log_level_hl = {
  "Normal",
  "Error",
  "Normal",
  "Normal",
  "WarningMsg",
--   -- DEBUG = vim.log.levels.DEBUG,
--   -- ERROR = vim.log.levels.ERROR,
--   -- INFO = vim.log.levels.INFO,
--   -- TRACE = vim.log.levels.TRACE,
--   -- WARN = vim.log.levels.WARN,
}

local printh = function(msg, hlgroup)
  -- TODO: neovim does not retain highlight unlike :echom does, see neovim#13812            
  -- vim.api.nvim_echo({{ msg, hlgroup }}, true, {})                                        
  hlgroup = hlgroup or 'Normal'
  msg = vim.fn.escape(msg, '"')
  local cmd = [[echohl $hlgroup | echomsg "$msg" | echohl None]]
  cmd = cmd:gsub('%$(%w+)', { msg = msg, hlgroup = hlgroup })
  vim.cmd(cmd)
end

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
  -- repeat log counting
  if M.last_log_msg == val then
    M.last_log_msg_count = M.last_log_msg_count + 1
  else
    M.last_log_msg_count = 0
  end
  M.last_log_msg = val

  local msg = sanitize_value(val)

  local src = get_caller_src(opts.stack_lvl_off or 0)

  local count = M.last_log_msg_count > 0 and ' ×'..M.last_log_msg_count or ''

  printh(src..' '..msg..count, opts.hl)
end

M.log = {
  dbg = function(val) M.process(val, { hl = "NotifyDEBUGBorder"}) end,
  err = function(val) M.process(val, { hl = "NotifyERRORBorder" }) end,
  info = function(val) M.process(val, { hl = "NotifyINFOBorder" }) end,
  trace = function(val) M.process(val, { hl = "NotifyTRACEBorder" }) end,
  warn = function(val) M.process(val, { hl = "NotifyWARNBorder" }) end,
}

setmetatable(M.log, {
  __call = function(self, val)
    M.process(val, { hl = "NotifyINFOBorder"})
  end
})

return M
