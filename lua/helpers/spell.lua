local keys = require "helpers.keys"

local function toggle_spell()
  if vim.opt.spell:get() then
    vim.opt_local.spell = false
    vim.opt_local.spelllang = "en"
  else
    vim.opt_local.spell = true
    vim.opt_local.spelllang = {"en_us"}
  end
end

keys.map('n', '<Leader>t', toggle_spell)
keys.map('n', '<Leader>s', "[s1z=``")

-- hi friend
