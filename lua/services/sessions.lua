--- defines session managment.
-- @module sessions
local M = {}

---@diagnostic disable: undefined-global

M.setup = U.Service({{FT.SESSION, "setup"}}, {{FT.PLUGIN, "mini.nvim"}}, function()
  local mini_session = require 'mini.sessions'
  mini_session.setup {
    autoread = false,
    autowrite = true,
    -- TODO: create session dir if not found
    force = { read = true, write = true, delete = true },
    hooks = {
      pre = { read = nil, write = nil, delete = nil },
      post = { read = nil, write = nil, delete = nil },
    },
    verbose = { read = false, write = false, delete = false },
  }

  vim.cmd [[
    augroup persist_folds
      autocmd!
      autocmd BufWritePost *.* mkview
      autocmd BufWinLeave *.* mkview
      autocmd BufWinEnter *.* silent! loadview
    augroup persist_folds
  ]]
end)

M.get_current = U.Service(function()
  local this_session = vim.v.this_session

  if #this_session > 0 then
    local session_file_path_arr = vim.split(vim.v.this_session, '/', {})
    local session_name = session_file_path_arr[#session_file_path_arr]
    return session_name
  else
    return nil
  end
end)

M.get_all = U.Service({{FT.SESSION, "setup"}}, function()
  local session_names = {}
  for session_name, _ in pairs(MiniSessions.detected) do
    table.insert(session_names, session_name)
  end
  return session_names
end)

M.save = U.Service({{FT.SESSION, "setup"}}, function(session_name)
  MiniSessions.write(session_name, {})
end)

M.load = U.Service({{FT.SESSION, "setup"}}, function(session_name)
  -- load last session if no session name provided
  session_name = session_name or MiniSessions.get_latest()

  if vim.tbl_contains(M.get_all(), session_name) then
    MiniSessions.read(session_name, {})
  else
    log.warn('session "' .. session_name .. '" does not exist')
  end
end)

M.delete = U.Service({{FT.SESSION, "setup"}}, function(session_name)
  MiniSessions.delete(session_name, {})
end)

vim.api.nvim_create_user_command('SessionSave',       function(opts) M.save(opts.fargs[1]) end,     { nargs = 1, complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionLoad',       function(opts) M.load(opts.fargs[1]) end,     { nargs = '?', complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionDelete',     function(opts) M.delete(opts.fargs[1]) end,   { nargs = 1, complete = function() return M.get_all() end })

return M
