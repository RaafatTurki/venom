local U = require "helpers.utils"
local buffers = require "helpers.buffers"
local log = require "logger".log
-- local mason = require "plugins.mason"
-- local dap = mason and mason.dap or nil

local M = {}

local function session_file()
  return vim.fn.getcwd() .. '/.venom.json'
end

M.local_session_file = session_file
M.is_in_local_session = false

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup("LocalSessions", { clear = true }),
  callback = function(ev)
    if M.is_in_local_session then M.save() end
  end
})

---@class SessionData
---@field buffers { current_file_index: number, file_paths: string[] }
------@field dap { breakpoints: { file_path: number[] } }

function M.save()
  ---@type SessionData
  local sdata = {
    buffers = buffers and buffers.aggregate() or nil,
    -- dap = dap.aggregate or nil,
  }

  -- write session file
  U.file_write(session_file(), vim.fn.json_encode(sdata))

  -- load if session isn't already loaded
  if not M.is_in_local_session then M.load() end
end

function M.load()
  -- prompt to save a new session if doesn't exist and exit
  if not U.is_file_exists(session_file()) then
    vim.schedule(function()
      if U.confirm_yes_no('Local session file does not exist. Create one?') then
        M.save()
      end
    end)
    return
  end

  -- read session file
  ---@type SessionData?
  local sdata = vim.fn.json_decode(U.file_read(session_file()))
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
  local del_result = U.file_del(session_file())
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
