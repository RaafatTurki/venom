local M = {}

M.map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

M.buf_map = function(buf, mode, lhs, rhs, desc)
  vim.api.nvim_buf_set_keymap(buf, mode, lhs, rhs, { silent = true, desc = desc })
end

M.set_leader = function(key)
  vim.g.mapleader = key
  vim.g.maplocalleader = key
  M.map({ "n", "v" }, key, "<nop>")
end

return M
