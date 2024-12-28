local keys = require "helpers.keys"

local function toggle_ignorecase()
  if vim.opt.ignorecase:get() then
    vim.opt_local.ignorecase = false
  else
    vim.opt_local.ignorecase = true
  end
end

keys.map('n', '<Leader>i', toggle_ignorecase)
-- keys.map('n', '<Leader>s', "[s1z=``")
