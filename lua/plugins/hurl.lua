local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.hurl.url }

M.dependencies = {
  plugins_info.plenary.url,
  plugins_info.nui.url,
}

M.ft = "hurl"

M.config = function()
  require "hurl".setup {
    -- show_notification = true,
    env_file = {
      '.env',
    },
    mode = "popup",
    popup_position = '0%',
    popup_size = {
      width = '100%',
      height = '60%',
    },
  }
end

return M
