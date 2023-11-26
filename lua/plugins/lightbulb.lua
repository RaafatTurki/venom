local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons

local M = { plugins_info.lightbulb.url }

M.config = function()
  require "nvim-lightbulb".setup({
    autocmd = { enabled = true },
    virtual_text = {
      enabled = true,
      text = icons.code_action.code_action,
      -- Highlight group to highlight the virtual text.
      hl = "DiagnosticSignWarn",
      -- How to combine other highlights with text highlight.
      -- See `hl_mode` of |nvim_buf_set_extmark|.
      hl_mode = "combine",
    }
  })
end

return M
