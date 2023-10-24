local U = require "helpers.utils"

vim.api.nvim_create_autocmd({ "ModeChanged" }, {
  callback = function(ev)
    -- make it work on statuscolumn custom numbering (with ranges over visual selection)
    local hl = vim.api.nvim_get_hl(0, { name = U.get_mode_hl() or "Normal" })
    local curline_hl = vim.api.nvim_get_hl(0, { name = 'CursorLine' })
    vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = hl.fg, bg = curline_hl.bg })
  end
})
