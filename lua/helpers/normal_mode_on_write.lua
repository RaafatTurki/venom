vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function(ev)
    local vimode = vim.api.nvim_get_mode().mode
    if vim.snippet.active() then vim.snippet.stop() end
    if vimode == 'i' then vim.cmd.stopinsert() end
  end,
})
