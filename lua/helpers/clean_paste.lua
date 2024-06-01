local keys = require "helpers.keys"

local function clean_paste()
  local clipboard_reg = '*'
  if vim.fn.has('unnamedplus') == 1 then clipboard_reg = '+' end

  local yanked_text = vim.fn.getreg(clipboard_reg)
  local cleaned_text = string.gsub(yanked_text, "\r", "")

  vim.fn.setreg(clipboard_reg, cleaned_text)
  vim.cmd('normal! "' .. clipboard_reg .. 'p')
end

keys.map('n', 'p', clean_paste)
