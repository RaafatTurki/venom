local U = require "helpers.utils"
local buffers = require "helpers.buffers"
-- local mason = require "plugins.mason"
-- local dap = mason and mason.dap or nil

local M = {}

M.local_session_file = vim.fn.getcwd() .. '/.venom.json'
M.is_in_local_session = false

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function(ev)
    if M.is_in_local_session then M.save() end
  end
})

---@class SessionData
---@field buffers { current_file_index: number, file_paths: string[] }
---@field dap { breakpoints: { file_path: number[] } }

function M.save()
  ---@type SessionData
  local sdata = {}

  if buffers then sdata.buffers = buffers.aggregate() end
  -- if dap then sdata.dap = dap.aggregate() end

  -- write session file
  U.file_write(M.local_session_file, vim.fn.json_encode(sdata))

  -- load if session isn't already loaded
  if not M.is_in_local_session then M.load() end
end

function M.load()
  -- prompt to save a new session if doesn't exist and exit
  if not U.is_file_exists(M.local_session_file) then
    vim.schedule(function()
      if U.confirm_yes_no('Local session file does not exist. Create one?') then
        M.save()
      end
    end)
    return
  end

  -- read session file
  ---@type SessionData?
  local sdata = vim.fn.json_decode(U.file_read(M.local_session_file))
  if not sdata then
    log.err("local session data is corrupted")
    return
  end

  -- populate modules with decoded data
  -- curr_branch = decoded_data.git_branches[U.get_curr_git_branch()]
  if sdata.buffers then buffers.populate(sdata.buffers) end
  -- if sdata.dap then dap.populate(sdata.dap) end

  -- set local session bool
  M.is_in_local_session = true
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
