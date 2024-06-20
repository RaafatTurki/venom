local plugins_info = require "helpers.plugins_info"

local M = {
  plugins_info.highlight_colors
}

M.config = function()
  require 'nvim-highlight-colors'.setup {
    render = 'background', -- background, foreground, virtual
    virtual_symbol = '■',
    enable_named_colors = true,
    enable_tailwind = true,
  }
end

return M
