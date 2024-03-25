local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = { plugins_info.codeium.url }

M.dependencies = {
  plugins_info.plenary.url,
}

M.config = function()
  require 'codeium'.setup {
    enable_chat = true,
  }

  -- -- disable if cwd is sensitive
  -- local is_cwd_sensitive = function()
  --   -- local curr_dir = vim.fn.getcwd()
  --   -- local home_dir = os.getenv("HOME")
  --   -- local code_path = home_dir .. "/code"
  --   return true
  -- end

  -- if not is_cwd_sensitive() then
  --   vim.cmd [[Copilot disable]]
  -- end

  -- keys.map("i", "<M-z>", function() require("copilot.suggestion").accept() end, "Accept copilot suggestion")
  -- keys.map("i", "<M-x>", function() require("copilot.suggestion").dismiss() end, "Dismiss copilot suggestion")
  -- keys.map("i", "<M-Left>", function() require("copilot.suggestion").next() end, "Next copilot suggestion")
  -- keys.map("i", "<M-Right>", function() require("copilot.suggestion").prev() end, "Previous copilot suggestion")
end

return M
