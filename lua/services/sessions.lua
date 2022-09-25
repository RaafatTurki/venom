--- defines session managment.
-- @module sessions
local M = {}

M.setup = U.Service():provide(FT.SESSION, "setup"):require(FT.PLUGIN, "mini.nvim"):new(function()
  local resession = require 'resession'
  resession.setup {
    -- dir = "$XDG_DATA_HOME/nvim_data/sessions/"
    -- dir = "/home/potato/.local/share/nvim_data/sessions/"
  }

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      resession.save(resession.get_current())
      resession.save("last")
    end,
  })
end)

M.get_all = U.Service():require(FT.SESSION, "setup"):new(function()
  require 'resession'.list()
end)

M.save = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  require 'resession'.save(session_name)
end)

M.load = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  require 'resession'.load(session_name)
end)

M.delete = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  require 'resession'.delete(session_name)
end)

M.load_cli = U.Service():new(function(session_name)
  if venom.features:has(FT.SESSION, 'setup') then
    M.load(session_name)
  else
    PluginManager.event_post_complete:sub(function()
      M.load(session_name)
    end)
  end
end)

vim.api.nvim_create_user_command('SessionSave',       function(opts) M.save(opts.fargs[1]) end,     { nargs = 1, complete = function() M.get_all() end })
vim.api.nvim_create_user_command('SessionLoad',       function(opts) M.load(opts.fargs[1]) end,     { nargs = 1, complete = function() M.get_all() end })
vim.api.nvim_create_user_command('SessionDelete',     function(opts) M.delete(opts.fargs[1]) end,   { nargs = 1, complete = function() M.get_all() end })
vim.api.nvim_create_user_command('SessionLoadLast',   function(opts) M.load() end,                  {})
vim.api.nvim_create_user_command('SessionLoadCLI',    function(opts) M.load_cli(opts.fargs[1]) end, { nargs = 1, complete = function() M.get_all() end })

return M
