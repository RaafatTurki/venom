local plugins_info = require "helpers.plugins_info"

local M = {
  plugins_info.fidget.url,
}

M.config = function()
  require "fidget".setup {
  }
end

return M
