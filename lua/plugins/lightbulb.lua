local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons

local M = { plugins_info.lightbulb }

M.config = function()
  require "nvim-lightbulb".setup {
    autocmd = { enabled = true },
    sign = {
      enabled = true,
      text = icons.code_action.code_action,
      hl = "DiagnosticSignWarn",
    }
  }
end

return M
