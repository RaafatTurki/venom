vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function(ev)
    vim.hl.on_yank({ higroup = "Search", timeout = vim.o.timeoutlen })
  end
})
