local U = require "helpers.utils"

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  callback = function(ev)
    vim.cmd [[silent! mkview]]
    -- if not U.is_buf_huge(ev.buf) then
    -- end
  end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(ev)
    vim.cmd [[silent! loadview]]
    -- if not U.is_buf_huge(ev.buf) then
    -- end
  end
})
