local neocodeium = require "neocodeium"

neocodeium.setup {
  show_label = false,
  filter = function(bufnr)
    if vim.startswith(vim.api.nvim_buf_get_name(bufnr), ".env") then return false end
    return true
  end,
  silent = true,
  filetypes = {
    TelescopePrompt = false,
    ["dap-repl"] = false,
  },
}

vim.keymap.set("i", "<M-z>", neocodeium.accept)
vim.keymap.set("i", "<M-x>", neocodeium.cycle_or_complete)
vim.keymap.set("i", "<M-e>", neocodeium.clear)
