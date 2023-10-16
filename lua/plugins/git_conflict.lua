local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = { plugins_info.git_conflict.url }

M.config = function()
  local git_conflict = require "git-conflict"

  git_conflict.setup {
    default_commands = true,
    default_mappings = false,
    disable_diagnostics = false,
    highlights = {
      current = 'GitConflictCurrent',
      incoming = 'GitConflictIncoming',
    }
  }

  -- keys.map("n", "z<Right>", fold_cycle.open, "Open fold")
end

return M
