local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local precomputed_colors = require "helpers.precomputed_colors"

local M = { plugins_info.ccc.url }

M.config = function()
  local ccc = require "ccc"
  -- log(ccc.mapping)

  ccc.setup {
    default_color = "#07080F",

    bar_char = "━",
    point_char = "┷",
    bar_len = 32,
    alpha_show = "hide",
    win_opts = {
      border = "single",
    },
    -- so the picker can properly read the precomputed named color strings
    pickers = {
      ccc.picker.custom_entries(precomputed_colors.all),
    },
    mappings = {
      ['<Left>'] = ccc.mapping.decrease1,
      ['<Right>'] = ccc.mapping.increase1,
      ['<C-Left>'] = ccc.mapping.decrease10,
      ['<C-Right>'] = ccc.mapping.increase10,
      ['<S-Left>'] = ccc.mapping.set0,
      ['<S-Right>'] = ccc.mapping.set100,
      -- H = ccc.mapping.none,
    }
  }

  keys.map("n", "cc", "<CMD>CccConvert<CR>", "Color convert")
  keys.map("n", "cp", "<CMD>CccPick<CR>", "Color pick")
end

return M
