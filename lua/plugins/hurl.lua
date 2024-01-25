local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.hurl.url }

M.dependencies = {
  plugins_info.nui.url,
}

M.ft = "hurl"

M.config = function()
  require "hurl".setup {
    -- env_file = {
    --   'example.env',
    -- },
    mode = "popup",
    -- mode = "split",
  }
end

return M
