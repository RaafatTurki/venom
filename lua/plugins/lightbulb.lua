local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons

local M = { plugins_info.lightbulb.url }

M.config = function()
  require "nvim-lightbulb".setup({
    autocmd = { enabled = true },
    virtual_text = {
      enabled = false,
      text = icons.code_action.code_action,
      hl = "DiagnosticSignWarn",
    }
  })
end

return M
