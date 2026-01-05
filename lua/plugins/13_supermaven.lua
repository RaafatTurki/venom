require "supermaven-nvim".setup {
  condition = function()
    return not vim.b.large_buf
  end,
  ignore_filetypes = {
    snacks_input = true,
  },
  keymaps = {
    accept_suggestion = "<M-z>",
    clear_suggestion = "<M-x>",
    accept_word = "<M-Z>",
  },
}

-- NOTE: supermaven has a disable function that could be used for sensitive dirs
