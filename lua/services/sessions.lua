--- defines session managment
-- @module configs
local M = {}

M.setup = U.Service():provide(FT.SESSION, "setup"):require(FT.PLUGIN, "mini.nvim"):new(function()
  require 'mini.sessions'.setup {
    autoread = false,
    autowrite = true,
    directory = os.getenv('XDG_DATA_HOME')..'/nvim_data/sessions',
    file = 'session.vim',
    force = { read = true, write = true, delete = true },
    verbose = { read = false, write = false, delete = false },
    hooks = {
      post = {
        read = function()
          local json_file_path = M.get_persistent_data_file_path()
          if (not U.is_file_exists(json_file_path)) then return end
          venom.persistent = vim.json.decode(U.file_read(json_file_path))
        end,
        write = function()
          if (vim.tbl_isempty(venom.persistent)) then return end
          U.file_write(M.get_persistent_data_file_path(), vim.json.encode(venom.persistent))
        end,
      },
      pre = {
        delete = function()
          M.delete_data()
        end
      }
    },
  }
end)

M.get_persistent_data_file_path = U.Service():require(FT.SESSION, "setup"):new(function()
  local path_arr = U.cut(vim.v.this_session, '/')
  local session_name = table.remove(path_arr, #path_arr)
  
  MiniSessions = MiniSessions
  if (U.join(path_arr, '/') == MiniSessions.config.directory) then
    table.remove(path_arr, #path_arr)
    table.insert(path_arr, #path_arr+1, 'persistent_data')
    table.insert(path_arr, #path_arr+1, session_name..'.json')
    return U.join(path_arr, '/')
  else
    table.insert(path_arr, #path_arr+1, session_name..'.json')
    return U.join(path_arr, '/')
  end
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

M.delete_data = U.Service():require(FT.SESSION, "setup"):new(function(session_name)
  os.remove(M.get_persistent_data_file_path())
  venom.persistent = {}
end)

M.select = U.Service():require(FT.SESSION, "setup"):new(function()
  require 'mini.sessions'.select()
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

local function get_all_names()
  local sessions_objs = M.get_all()
  local session_names = {}

  for session_name, _ in pairs(sessions_objs) do
    table.insert(session_names, session_name)
  end

  return session_names
end

vim.api.nvim_create_user_command('SessionSave',       function(opts) M.save(opts.fargs[1]) end,     { nargs = 1, complete = get_all_names })
vim.api.nvim_create_user_command('SessionLoad',       function(opts) M.load(opts.fargs[1]) end,     { nargs = 1, complete = get_all_names })
vim.api.nvim_create_user_command('SessionDelete',     function(opts) M.delete(opts.fargs[1]) end,   { nargs = 1, complete = get_all_names })
vim.api.nvim_create_user_command('SessionDeleteData', function(opts) M.delete_data() end,           {})
vim.api.nvim_create_user_command('SessionLoadLast',   function(opts) M.load() end,                  {})
vim.api.nvim_create_user_command('SessionSelect',     function(opts) M.select() end,                {})
vim.api.nvim_create_user_command('SessionLoadCLI',    function(opts) M.load_cli(opts.fargs[1]) end, { nargs = 1, complete = get_all_names })

return M
