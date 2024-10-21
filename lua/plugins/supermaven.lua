local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = {
  plugins_info.supermaven
}

M.event = "InsertEnter"

M.config = function()
  require "supermaven-nvim".setup {
    keymaps = {
      accept_suggestion = "<M-z>",
      clear_suggestion = "<M-x>",
      accept_word = "<M-Z>",
    },
  }

  -- disable if cwd is sensitive
  -- local is_cwd_sensitive = function()
  --   -- local curr_dir = vim.fn.getcwd()
  --   -- local home_dir = os.getenv("HOME")
  --   -- local code_path = home_dir .. "/code"
  --   return true
  -- end
  --
  -- if not is_cwd_sensitive() then
  --   vim.cmd [[supermaven Stop]]
  -- end
end

return M
