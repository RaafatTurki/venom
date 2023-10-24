local buffers = require "helpers.buffers"


vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  callback = function(ev)
    local buf_i = buffers.buflist:get_buf_index({bufnr = ev.buf})
    if not buf_i then return end
    if not buffers.buflist:get_buf_info(buf_i).buf.is_huge then
      vim.cmd [[silent! mkview]]
    end
  end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(ev)
    local buf_i = buffers.buflist:get_buf_index({bufnr = ev.buf})
    if not buf_i then return end
    if not buffers.buflist:get_buf_info(buf_i).buf.is_huge then
      vim.cmd [[silent! loadview]]
    end
  end
})
