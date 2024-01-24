local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons

local M = { plugins_info.corn.url }

-- M.dev = true

M.config = function()
  -- disable virtual text diags
  vim.diagnostic.config({ virtual_text = false })

  require "corn".setup {
    -- auto_cmds = false,
    sort_method = 'column',
    border_style = 'none',
    -- scope = 'file',
    blacklisted_modes = { 'i' },
    icons = {
      error = icons.diag.Error,
      warn = icons.diag.Warn,
      hint = icons.diag.Hint,
      info = icons.diag.Info,
    },
    on_toggle = function(is_hidden)
      -- toggle virtual_text diags back on when corn is off and vise versa
      vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
    end,
  }
end

return M
