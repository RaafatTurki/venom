local U = require 'utils'

local M = {}

events.session_write_pre = U.Event("session_write_pre"):new()

M.local_session_file = vim.fn.getcwd() .. '/.venom.json'
M.is_in_local_session = false

M.setup = service({{feat.SESSION, "setup"}}, nil, function()
  -- auto save on leave
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('auto_save_session_on_leave', {}),
    callback = function(ctx)
      if M.is_in_local_session then M.save() end
    end
  })

  -- persist fold, curpos and pwd with mkview automatically
  vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufWritePost' }, {
    group = vim.api.nvim_create_augroup('persist_mkview', {}),
    callback = function()
      vim.cmd [[silent! mkview]]
    end
  })
  vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('persist_loadview', {}),
    callback = function()
      vim.cmd [[silent! loadview]]
    end
  })

  -- save session on fs update event
  events.fs_update:sub(function()
    if M.is_in_local_session then
      M.save()
    end
  end)

  -- save session on buflist update
  events.buflist_update:sub(function()
    if M.is_in_local_session then
      M.save()
    end
  end)
end)

M.save = service({{feat.SESSION, "setup"}}, function()
  -- write session file
  U.file_write(M.local_session_file, vim.fn.json_encode({
    general = {
      -- cwd = vim.fn.getcwd(),
      -- globals = {},
    },
    buffers = Buffers.aggregate(),
  }))

  -- load if session isn't loaded
  if not M.is_in_local_session then M.load() end
end)

M.load = service({{feat.SESSION, "setup"}}, function()
  if U.is_file_exists(M.local_session_file) then
    -- read session file
    local json = U.file_read(M.local_session_file)
    local decoded_data = vim.fn.json_decode(json)
    
    if decoded_data then
      -- vim.api.nvim_set_current_dir(data.general.cwd)
      Buffers.populate(decoded_data.buffers)
      M.is_in_local_session = true
    else
      log.err("local session data is corrupted")
    end
  else
    log.warn('local session file does not exist')
  end
end)

M.delete = service({{feat.SESSION, "setup"}}, function()
  local del_result = U.file_del(M.local_session_file)
  if del_result then
    if M.is_in_local_session then
      M.is_in_local_session = false
    end
  end
end)

vim.api.nvim_create_user_command('SessionSave',       function(opts) M.save() end, {})
vim.api.nvim_create_user_command('SessionLoad',       function(opts) M.load() end, {})
vim.api.nvim_create_user_command('SessionDelete',     function(opts) M.delete() end, {})

return M
