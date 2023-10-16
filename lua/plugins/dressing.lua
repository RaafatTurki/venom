local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.dressing.url }

M.config = function()
  require "dressing".setup {
    input = {
      -- enabled = false
      border = "single",
      relative = "editor",
      title_pos = "center",
    },
    select = {
      -- enabled = false
      backend = { "builtin" },
      builtin = {
        border = "single",
        relative = "editor",
      }
    }
  }
end

return M
