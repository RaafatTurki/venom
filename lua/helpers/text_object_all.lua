local map = require "helpers.keys".map

-- NOTE: this is a modified version of https://vi.stackexchange.com/a/24811

map("o", "aa", function()
  local restore_view = vim.fn.winsaveview()
  vim.cmd "normal! ggVG"

  -- for delete/change ALL, we don't wish to restore cursor position
  if vim.tbl_contains({ "c", "d" }, vim.v.operator) then return end

  vim.schedule(function() vim.fn.winrestview(restore_view) end)
end, "Whole buffer textobject")
