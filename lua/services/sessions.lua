local M = {}

M.sessions_path = vim.fn.stdpath("data") .. '/sessions/'
M.current_session_name = nil

M.setup = U.Service({{FT.SESSION, "setup"}}, {}, function()
  -- ensure sessions path exist
  if vim.fn.isdirectory(M.sessions_path) == 0 then
    vim.loop.fs_mkdir(M.sessions_path, 493)
    log.info("no sessions dir found " .. M.sessions_path .. " created")
  end

  -- auto save on leave
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('auto_save_session_on_leave', {}),
    callback = function(ctx)
      if M.current_session_name then
        M.save()
      end
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

  Events.fs_update:sub(function()
    if M.get_current() then
      M.save()
    end
  end)

  Events.buflist_update:sub(function()
    if M.get_current() then
      M.save()
    end
  end)
end)

M.get_current = U.Service(function()
  return M.current_session_name
end)

M.get_all = U.Service({{FT.SESSION, "setup"}}, function()
  local session_names = {}
  
  -- remove the .json extension (last 5 chars)
  for i, session_file_name in ipairs(U.scan_dir(M.sessions_path)) do
    table.insert(session_names, string.sub(session_file_name, 1, -6))
  end

  return session_names
end)

M.save = U.Service({{FT.SESSION, "setup"}}, function(session_name)
  session_name = session_name or M.get_current()
  if not session_name then
    log.err("no session name found")
    return
  end
  
  local json = vim.fn.json_encode({
    general = {
      cwd = vim.fn.getcwd(),
      -- globals = {},
    },
    buffers = Buffers.serialize()
  })

  U.file_write(M.sessions_path .. '/' .. session_name .. '.json', json)
end)

M.load = U.Service({{FT.SESSION, "setup"}}, function(session_name)
  if vim.tbl_contains(M.get_all(), session_name) then
    local json = U.file_read(M.sessions_path .. '/' .. session_name .. '.json')
    local data = vim.fn.json_decode(json)
    
    if data then
      vim.api.nvim_set_current_dir(data.general.cwd)
      Buffers.deserialize(data.buffers)
      M.current_session_name = session_name
    else
      log.err(session_name .. " session data is corrupted")
    end
  else
    log.warn('session "' .. session_name .. '" does not exist')
  end
end)

M.delete = U.Service({{FT.SESSION, "setup"}}, function(session_name)
  session_name = session_name or M.get_current()
  -- MiniSessions.delete(session_name, {})
  local res = U.file_del(M.sessions_path .. '/' .. session_name .. '.json')
  if res then
    if session_name == M.current_session_name then
      M.current_session_name = nil
    end
  end
end)

M.rename = U.Service({{FT.SESSION, "setup"}}, function(session_name, new_session_name)
  -- rename current session if no new_session_name is provided
  if new_session_name == nil then
    new_session_name = session_name
    session_name = M.get_current()
    if not session_name then
      log.err('no session name found')
      return
    end
  end

  local res = U.file_rename(M.sessions_path .. '/' .. session_name .. '.json', new_session_name .. '.json')
  if res and M.current_session_name == session_name then
    M.current_session_name = new_session_name
  end
end)

vim.api.nvim_create_user_command('SessionSave',       function(opts) M.save(opts.fargs[1]) end,     { nargs = '?', complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionLoad',       function(opts) M.load(opts.fargs[1]) end,     { nargs = 1, complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionDelete',     function(opts) M.delete(opts.fargs[1]) end,   { nargs = '?', complete = function() return M.get_all() end })
vim.api.nvim_create_user_command('SessionRename',     function(opts) M.rename(opts.fargs[1], opts.fargs[2]) end,   { nargs = '+', complete = function() return M.get_all() end })

return M
