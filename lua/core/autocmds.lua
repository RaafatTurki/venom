local U = require "helpers.utils"
local log = require "helpers.logger"

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function(ev)
    local vimode = vim.api.nvim_get_mode().mode
    -- exit insert mode if insert mode
    if vimode == 'i' then
      vim.cmd.stopinsert()
    end

    -- recompute folds if normal mode
    -- if vimode == 'n' then
    --   vim.cmd.edit()
    --   vim.api.nvim_feedkeys("zx", '', true)
    -- end
  end,
})

vim.api.nvim_create_autocmd({ "ModeChanged" }, {
  callback = function(ev)
    -- make it work on statuscolumn custom numbering (with ranges over visual selection)

    local hl = vim.api.nvim_get_hl(0, { name = U.get_mode_hl() or "Normal" })
    local curline_hl = vim.api.nvim_get_hl(0, { name = 'CursorLine' })
    vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = hl.fg, bg = curline_hl.bg })
  end
})

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  callback = function(ev)
    vim.cmd [[silent! mkview]]
  end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(ev)
    vim.cmd [[silent! loadview]]
  end
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function(ev)
    vim.fn.mkdir(vim.fn.fnamemodify(ev.file, ':p:h'), 'p')
  end
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function(ev)
    vim.highlight.on_yank({ higroup = "Search", timeout = vim.o.timeoutlen })
  end
})

