local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons
local keys = require "helpers.keys"

local M = { plugins_info.zen_mode }

M.config = function()
  require "zen-mode".setup {
    window = {
      backdrop = 1,
      width = 100,
    },
    plugins = {
      options = {
        enabled = false,
      },
    }
  }

  keys.map("n", "<leader>z", "<CMD>ZenMode<CR>")
end

return M
