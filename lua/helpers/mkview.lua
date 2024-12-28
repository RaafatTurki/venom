local U = require "helpers.utils"

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  callback = function(ev)
    -- bigfile check
    local ft = vim.api.nvim_get_option_value('filetype', { buf = ev.buf })
    if ft == "bigfile" then return end

    vim.cmd [[silent! mkview]]
  end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(ev)
    -- bigfile check
    local ft = vim.api.nvim_get_option_value('filetype', { buf = ev.buf })
    if ft == "bigfile" then return end

    vim.cmd [[silent! loadview]]
  end
})
