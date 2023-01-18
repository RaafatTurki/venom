--- defines session managment.
-- @module sessions
log = require 'logger'.log
U = require 'utils'

---@diagnostic disable: undefined-global
local M = {}

-- M.last_session_name = 'last'

M.setup = U.Service():provide(FT.SESSION, "setup"):require(FT.PLUGIN, "mini.nvim"):new(function()
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

  -- local resession = require 'resession'
  -- resession.setup {}

  -- vim.api.nvim_create_autocmd("VimLeavePre", {
  --   callback = function()
  --     -- resession.save(resession.get_current())
  --     -- resession.save(M.last_session_name)
  --     MiniSessions.save(M.last_session_name)
  --   end,
  -- })

  vim.cmd [[
    augroup persist_folds
      autocmd!
      autocmd BufWritePost *.* mkview
      autocmd BufWinLeave *.* mkview
      autocmd BufWinEnter *.* silent! loadview
    augroup END
  ]]
end)

M.get_current = U.Service():new(function()
  local this_session = vim.v.this_session

  if #this_session > 0 then
    local session_file_path_arr = vim.split(vim.v.this_session, '/')
    local session_name = session_file_path_arr[#session_file_path_arr]
    return session_name
  else
    return nil
  end

  -- return require'resession'.get_current()
end)

M.get_all = U.Service():require(FT.SESSION, "setup"):new(function()
  local session_names = {}
  for session_name, _ in pairs(MiniSessions.detected) do
    table.insert(session_names, session_name)
  end
  return session_names

  -- return require 'resession'.list()
end)

M.save = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  MiniSessions.write(session_name, {})

  -- require 'resession'.save(session_name)
end)

M.load = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  if vim.tbl_contains(M.get_all(), session_name) then
    MiniSessions.read(session_name, {})
  else
    log.warn('session "' .. session_name .. '" does not exist')
  end

  -- require 'resession'.load(session_name)
end)

M.load_last = U.Service():require(FT.SESSION, "setup"):new(function(last_session_name)
  last_session_name = MiniSessions.get_latest()
  MiniSessions.read(last_session_name, {})

  -- require 'resession'.load(M.last_session_name)
end)

M.delete = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  MiniSessions.delete(session_name, {})

  -- require 'resession'.delete(session_name)
end)

-- M.resave = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
--   -- if session_name == nil then
--   --   session_name = M.get_current()
--   --
--   --   if session_name == nil then
--   --     log.warn("No session name provided and no current session found")
--   --     return
--   --   end
--   -- end
--   --
--   -- M.delete(session_name)
--   -- M.save(session_name)
-- end)

M.load_cli = U.Service():new(function(session_name)
  if venom.features:has(FT.SESSION, 'setup') then
    M.load(session_name)
  else
    PluginManager.event_post_complete:sub(function()
      M.load(session_name)
    end)
  end
end)

vim.api.nvim_create_user_command('SessionSave',       function(opts) M.save(opts.fargs[1]) end,     { nargs = 1, complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionLoad',       function(opts) M.load(opts.fargs[1]) end,     { nargs = 1, complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionDelete',     function(opts) M.delete(opts.fargs[1]) end,   { nargs = 1, complete = function() return M.get_all() end })
-- vim.api.nvim_create_user_command('SessionResave',     function(opts) M.resave(opts.fargs[1]) end,   { nargs = '?', complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionLoadLast',   function(opts) M.load_last() end,             {})
vim.api.nvim_create_user_command('SessionLoadCLI',    function(opts) M.load_cli(opts.fargs[1]) end, { nargs = 1 })

return M
