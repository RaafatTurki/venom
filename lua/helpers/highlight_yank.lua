vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function(ev)
    vim.highlight.on_yank({ higroup = "Search", timeout = vim.o.timeoutlen })
  end
})
