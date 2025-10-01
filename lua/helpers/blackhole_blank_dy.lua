local function is_current_line_blank()
  local line = vim.api.nvim_get_current_line()
  return line:match('^%s*$')
end

local function blackhole_if_curr_line_blank(op)
  if is_current_line_blank() then
    return '"_' .. op
  else
    return op
  end
end

-- normal mode operator mappings
vim.keymap.set({'n', 'x'}, 'd', function()
  return blackhole_if_curr_line_blank('d')
end, { noremap = true, expr = true, desc = "Smart Delete Operator" })

vim.keymap.set({'n', 'x'}, 'y', function()
  return blackhole_if_curr_line_blank('y')
end, { noremap = true, expr = true, desc = "Smart Yank Operator" })

-- line-wise mappings (e.g., 'dd', 'yy')
-- These are necessary because 'dd' and 'yy' are commands, not operator+motion.
-- NOTE: 'dd' and 'yy' are implicitly covered by the smart operators above when used without a motion (e.g., 'd' then 'd')
-- but mapping the *command* 'dd' directly is cleaner for the common case.

-- normal mode operator mappings
vim.keymap.set('n', 'dd', function()
  if is_current_line_blank() then
    return '"_dd'
  else
    return 'dd'
  end
end, { noremap = true, expr = true, desc = "Smart Delete Line" })

vim.keymap.set('n', 'yy', function()
  if is_current_line_blank() then
    return '"_yy'
  else
    return 'yy'
  end
end, { noremap = true, expr = true, desc = "Smart Yank Line" })

-- NOTE: visual mode line-wise/block-wise delete and yank are covered by the operator mappings above.
