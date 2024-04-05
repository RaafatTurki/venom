local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.dressing.url }

M.config = function()
  require "dressing".setup {
    input = {
      border = "single",
      relative = "editor",
      title_pos = "center",
    },
    select = {
      enabled = false -- mini.pick
      -- backend = { "builtin" },
      -- builtin = {
      --   border = "single",
      --   relative = "editor",
      -- }
    }
  }
end

return M
