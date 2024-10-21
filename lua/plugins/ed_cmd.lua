local plugins_info = require "helpers.plugins_info"

M = { plugins_info.ed_cmd }

M.config = function()
  require("ed-cmd").setup({})
end

return {}
