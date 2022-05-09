--- defines session managment
-- @module configs
local M = {}

M.setup = U.Service():provide(FT.SESSION, "setup"):require(FT.PLUGIN, "mini.nvim"):new(function()
  require 'mini.sessions'.setup {
    autoread = false,
    autowrite = true,
    directory = vim.fn.stdpath('data')..'/sessions',
    file = 'session.vim',
    force = { read = false, write = true, delete = false },
    verbose = { read = false, write = false, delete = false },
  }
end)

M.get_all = U.Service():require(FT.SESSION, "setup"):new(function()
  return require 'mini.sessions'.detected
end)

M.get_last = U.Service():require(FT.SESSION, "setup"):new(function()
  return require 'mini.sessions'.get_lastest()
end)

M.save = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  require 'mini.sessions'.write(session_name)
end)

M.load = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  require 'mini.sessions'.read(session_name)
end)

M.delete = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  require 'mini.sessions'.delete(session_name)
end)

function get_all_names()
  local sessions_objs = M.get_all:invoke()
  local session_names = {}

  for session_name, _ in pairs(sessions_objs) do
    table.insert(session_names, session_name)
  end

  return session_names
end

vim.api.nvim_create_user_command('SessionSave', function(opts) M.save:invoke(opts.fargs[1]) end, { nargs = 1, complete = get_all_names })
vim.api.nvim_create_user_command('SessionLoad', function(opts) M.load:invoke(opts.fargs[1]) end, { nargs = 1, complete = get_all_names })
vim.api.nvim_create_user_command('SessionDelete', function(opts) M.delete:invoke(opts.fargs[1]) end, { nargs = 1, complete = get_all_names })
vim.api.nvim_create_user_command('SessionLoadLast', function(opts) M.load:invoke() end, {})

return M
