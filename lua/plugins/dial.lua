local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = { plugins_info.dial.url }

M.config = function()
  local augend = require "dial.augend"
  local dial_map = require "dial.map"

  require "dial.config".augends:register_group {
    default = {
      augend.integer.alias.binary,
      augend.integer.alias.octal,
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
      augend.semver.alias.semver,
      augend.date.alias["%Y-%m-%d"],
      augend.constant.alias.bool,
    },
  }

  local ft_augends = {
    lua = {
      augend.constant.new { elements = {"else", "elif", "if"} },
    },
    typescript = {
      augend.constant.new{ elements = {"let", "const"} },
    },
  }

  require "dial.config".augends:register_group(ft_augends)

  keys.map("n", "<C-a>",    function() dial_map.manipulate("increment", "normal") end, "")
  keys.map("n", "<C-x>",    function() dial_map.manipulate("decrement", "normal") end, "")
  keys.map("n", "g<C-a>",   function() dial_map.manipulate("increment", "gnormal") end, "")
  keys.map("n", "g<C-x>",   function() dial_map.manipulate("decrement", "gnormal") end, "")
  keys.map("v", "<C-a>",    function() dial_map.manipulate("increment", "visual") end, "")
  keys.map("v", "<C-x>",    function() dial_map.manipulate("decrement", "visual") end, "")
  keys.map("v", "g<C-a>",   function() dial_map.manipulate("increment", "gvisual") end, "")
  keys.map("v", "g<C-x>",   function() dial_map.manipulate("decrement", "gvisual") end, "")

  vim.api.nvim_create_autocmd({ "FileType" }, {
    callback = function(ev)
      local is_registerd_ft_augend = ft_augends[ev.match]
      if is_registerd_ft_augend then
        keys.buf_map(ev.buf, "n", "<C-a>", dial_map.inc_normal(ev.match), "")
        keys.buf_map(ev.buf, "n", "<C-x>", dial_map.dec_normal(ev.match), "")
      end
    end
  })
end

return M
