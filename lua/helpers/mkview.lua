local U = require "helpers.utils"

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  callback = function(ev)
    if not U.is_buf_huge(ev.buf) then
      vim.cmd [[silent! mkview]]
    end
  end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(ev)
    if not U.is_buf_huge(ev.buf) then
      vim.cmd [[silent! loadview]]
    end
  end
})
