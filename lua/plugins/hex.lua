local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.hex }

M.dev = true

M.config = function()
  require 'hex'.setup {}
end

return M
