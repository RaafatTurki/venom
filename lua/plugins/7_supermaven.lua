require "supermaven-nvim".setup {
  ignore_filetypes = {
    bigfile = true,
    snacks_input = true,
  },
  keymaps = {
    accept_suggestion = "<M-z>",
    clear_suggestion = "<M-x>",
    accept_word = "<M-Z>",
  },
}

-- NOTE: supermaven has a disable function that could be used for sensitive dirs
