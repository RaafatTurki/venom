local M = {}

M.map = function(mode, lhs, rhs, opts, autocmds)
  local o = {
    silent = true,
  }

  if type(opts) == "string" then
    o.desc = opts
  elseif type(opts) == "table" then
    o = vim.tbl_extend("force", opts, o)
  end

  if autocmds then
    vim.api.nvim_create_autocmd(autocmds, {
      callback = function()
        vim.keymap.set(mode, lhs, rhs, o)
      end
    })
  else
    vim.keymap.set(mode, lhs, rhs, o)
  end
end

M.buf_map = function(buf, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = buf })
end

M.set_leader = function(key)
  vim.g.mapleader = key
  vim.g.maplocalleader = key
  M.map({ "n", "v" }, key, "<nop>")
end

return M
