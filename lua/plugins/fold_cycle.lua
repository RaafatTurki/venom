local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = { plugins_info.fold_cycle.url }

M.config = function()
  local fold_cycle = require "fold-cycle"

  fold_cycle.setup {
    open_if_max_closed = false,
    close_if_max_opened = false,
    softwrap_movement_fix = false,
  }

  keys.map("n", "z<Right>", fold_cycle.open, "Open fold")
  keys.map("n", "z<Left>", fold_cycle.close, "Close fold")
  keys.map("n", "z<Down>", fold_cycle.open_all, "Open all folds")
  keys.map("n", "z<Up>", fold_cycle.close_all, "CLose all folds")
  keys.map("n", "za", fold_cycle.toggle_all, "Toggle all folds")
end

return M
