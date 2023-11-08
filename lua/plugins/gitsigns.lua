local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"

local M = { plugins_info.gitsigns.url }

M.config = function()
  local gitsigns = require "gitsigns"
  gitsigns.setup {
    signs = {
      add          = { text = '│' },
      change       = { text = '│' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
    },
    _extmark_signs = false, -- NOTE: using legacy signs to make them visible in statuscol.nvim
    max_file_length = 40000,
  }

  keys.map("n", "g<Left>",  gitsigns.prev_hunk, "")
  keys.map("n", "g<Right>", gitsigns.next_hunk, "")
  keys.map("n", "gs",       gitsigns.stage_hunk, "")
  keys.map("v", "gs",       function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, "")
  keys.map("n", "gr",       gitsigns.reset_hunk, "")
  keys.map("v", "gr",       function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, "")
  keys.map("n", "gS",       gitsigns.stage_buffer, "")
  keys.map("n", "gu",       gitsigns.undo_stage_hunk, "")
  keys.map("n", "gR",       gitsigns.reset_buffer, "")
  keys.map("n", "gp",       gitsigns.preview_hunk, "")
  keys.map("n", "gb",       function() gitsigns.blame_line{full=true} end, "")
  -- keys.map("n", "gB",       gitsigns.toggle_current_line_blame, "")
  -- keys.map("n", "gd",       gitsigns.diffthis, "")
  -- keys.map("n", "gD",       function() gitsigns.diffthis('~') end, "")
  -- keys.map('n', 'gx',       gitsigns.toggle_deleted, "")

  -- text object
  keys.map({'o', 'x'}, 'gh', ':<C-U>Gitsigns select_hunk<CR>', "")

  vim.api.nvim_create_autocmd('User', {
    pattern = 'GitConflictDetected',
    callback = function()
      vim.o.foldenable = false
      vim.diagnostic.disable()
    end
  })
end

return M
