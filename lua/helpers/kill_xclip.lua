-- kill xclip on VimLeave if last nvim instance is closed
vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("KillXclip", { clear = true }),
  callback =  function()
    os.execute("pkill xclip")
  end
})
