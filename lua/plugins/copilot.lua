local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = { plugins_info.copilot.url }

M.cmd = "Copilot"
M.build = ":Copilot auth"
M.event = "InsertEnter"

M.config = function()
  require "copilot".setup {
    -- filetypes = {
    --   sh = function ()
    --     -- disable for .env files
    --     if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then return false end
    --     return true
    --   end,
    -- },
    panel = {
      enabled = true,
      auto_refresh = true,
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      accept = false, -- disable built-in keymapping
    },
  }

  -- disable if cwd is sensitive
  local is_cwd_sensitive = function()
    -- local curr_dir = vim.fn.getcwd()
    -- local home_dir = os.getenv("HOME")
    -- local code_path = home_dir .. "/code"
    return true
  end

  if not is_cwd_sensitive() then
    vim.cmd [[Copilot disable]]
  end

  keys.map("i", "<M-z>", function() require("copilot.suggestion").accept() end, "Accept copilot suggestion")
  keys.map("i", "<M-x>", function() require("copilot.suggestion").dismiss() end, "Dismiss copilot suggestion")
  keys.map("i", "<M-Left>", function() require("copilot.suggestion").next() end, "Next copilot suggestion")
  keys.map("i", "<M-Right>", function() require("copilot.suggestion").prev() end, "Previous copilot suggestion")
end

-- return M
return {}
