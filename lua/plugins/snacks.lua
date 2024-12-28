local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons
local keys = require "helpers.keys"

local M = {
  plugins_info.snacks
}

M.config = function()
  require "snacks".setup {
    zen = {},
  }

  keys.map("n", "<leader>z", Snacks.zen.zen)
end

return M
