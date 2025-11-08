vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function(ev)
    vim.hl.on_yank({
      timeout = vim.o.timeoutlen,
      visual = true,
      higroup = "Search",
    })
  end
})
