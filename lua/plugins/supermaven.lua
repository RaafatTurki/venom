local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = {
  plugins_info.supermaven
}

M.event = "InsertEnter"

M.config = function()
  require "supermaven-nvim".setup {
    ignore_filetypes = { bigfile = true },
    keymaps = {
      accept_suggestion = "<M-z>",
      clear_suggestion = "<M-x>",
      accept_word = "<M-Z>",
    },
  }

  -- NOTE: supermaven has a disable function that could be used for sensitive dirs
end

return M
