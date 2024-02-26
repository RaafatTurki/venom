local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = { plugins_info.astrisk.url }

M.config = function()
  -- vim.g["asterisk#keeppos"] = 0

  keys.map({"n", "v", "o"}, "*",    "<Plug>(asterisk-*)",     "Astrisk *")
  keys.map({"n", "v", "o"}, "#",    "<Plug>(asterisk-#)",     "Astrisk #")
  keys.map({"n", "v", "o"}, "g*",   "<Plug>(asterisk-g*)",    "Astrisk g*")
  keys.map({"n", "v", "o"}, "g#",   "<Plug>(asterisk-g#)",    "Astrisk g#")
  keys.map({"n", "v", "o"}, "z*",   "<Plug>(asterisk-z*)",    "Astrisk z*")
  keys.map({"n", "v", "o"}, "gz*",  "<Plug>(asterisk-gz*)",   "Astrisk gz*")
  keys.map({"n", "v", "o"}, "z#",   "<Plug>(asterisk-z#)",    "Astrisk z#")
  keys.map({"n", "v", "o"}, "gz#",  "<Plug>(asterisk-gz#)",   "Astrisk gz#")
end

return M
