local U = require "helpers.utils"
local buffers = require "helpers.buffers"

local M = {}

M.local_session_file = vim.fn.getcwd() .. '/.venom.json'
M.is_in_local_session = false

-- TODO: make session managment git branch aware

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function(ev)
    if M.is_in_local_session then M.save() end
  end
})

-- TODO: save session on fs update event
-- events.fs_update:sub(function()
--   if M.is_in_local_session then
--     M.save()
--   end
-- end)

-- TODO: save session on buflist update
-- events.buflist_update:sub(function()
--   if M.is_in_local_session then
--     M.save()
--   end
-- end)


function M.save()
  -- write session file
  U.file_write(M.local_session_file, vim.fn.json_encode({
    buffers = buffers.aggregate(),
    -- dap = Dap.aggregate(),
  }))

  -- load if session isn't loaded
  if not M.is_in_local_session then M.load() end
end

function M.load()
  if U.is_file_exists(M.local_session_file) then
    -- read session file
    local json = U.file_read(M.local_session_file)
    local decoded_data = vim.fn.json_decode(json)

    -- populate modules with decoded data
    if decoded_data then
      buffers.populate(decoded_data.buffers)
      -- Dap.populate(decoded_data.dap)

      -- set local session bool
      M.is_in_local_session = true
    else
      log.err("local session data is corrupted")
    end
  else
    vim.schedule(function()
      if U.confirm_yes_no('Local session file does not exist. Create one?') then
        M.save()
      end
    end)
  end
end

function M.delete()
  local del_result = U.file_del(M.local_session_file)
  if del_result then
    if M.is_in_local_session then
      M.is_in_local_session = false
    end
  end
end

vim.api.nvim_create_user_command('SessionSave',       function(opts) M.save() end, {})
vim.api.nvim_create_user_command('SessionLoad',       function(opts) M.load() end, {})
vim.api.nvim_create_user_command('SessionDelete',     function(opts) M.delete() end, {})

return M
