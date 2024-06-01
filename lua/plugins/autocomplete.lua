local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = {
  plugins_info.autocomplete.url,
}

M.config = function()
  require "autocomplete.signature".setup {
    border = "single",
    debounce_delay = 500
  }
end

return M
