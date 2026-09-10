require "conform".setup {
  formatters_by_ft = {
    -- lua = { "stylua" },
    svelte = { "prettier_svelte" },
  },
  formatters = {
    prettier_svelte = {
      inherit = "prettier",
      prepend_args = { "--no-semi", "--print-width", "9999" },
    },
  },
  format_on_save = false,
}
