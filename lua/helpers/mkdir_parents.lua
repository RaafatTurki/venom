
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function(ev)
    vim.fn.mkdir(vim.fn.fnamemodify(ev.file, ':p:h'), 'p')
  end
})
