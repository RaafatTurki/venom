local U = require "helpers.utils"

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  callback = function(ev)
    -- maybe make a bigfile check here
    vim.cmd [[silent! mkview]]
  end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(ev)
    -- maybe make a bigfile check here
    vim.cmd [[silent! loadview]]
  end
})
