vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function(ev)
    local vimode = vim.api.nvim_get_mode().mode

    if vimode == 'i' then vim.cmd.stopinsert() end
  end,
})
