local M = {
  -- NOTE: first because some of its plugins need to be loaded first
  snacks                = "folke/snacks.nvim",

  plenary               = "nvim-lua/plenary.nvim",
  mini                  = "echasnovski/mini.nvim",
  edgy                  = "folke/edgy.nvim",
  neotree               = "nvim-neo-tree/neo-tree.nvim",
  nui                   = "MunifTanjim/nui.nvim",
  heirline              = "rebelot/heirline.nvim",
  corn                  = "RaafatTurki/corn.nvim",
  -- zen_mode              = "folke/zen-mode.nvim",
  highlight_colors      = "brenoprata10/nvim-highlight-colors",
  copilot               = "zbirenbaum/copilot.lua",
  supermaven            = "supermaven-inc/supermaven-nvim",
  blink                 = "Saghen/blink.cmp",
  hex                   = "RaafatTurki/hex.nvim",
  hurl                  = "jellydn/hurl.nvim",
  volt                  = "NvChad/volt",
  menu                  = "NvChad/menu",
  -- ed_cmd                = "smilhey/ed-cmd.nvim",
  -- autocomplete          = "deathbeam/autocomplete.nvim",
  -- cmp                   = "hrsh7th/nvim-cmp",
  -- cmp_path              = "hrsh7th/cmp-path",
  -- cmp_nvim_lsp          = "hrsh7th/cmp-nvim-lsp",
  -- cmp_cmdline           = "hrsh7th/cmp-cmdline",
  -- cmp_buffer            = "hrsh7th/cmp-buffer",
  -- cmp_nvim_lsp_signature_help = "hrsh7th/cmp-nvim-lsp-signature-help",
  -- cmp_rg                = "lukas-reineke/cmp-rg",
  -- cmp_nvim_lua          = "hrsh7th/cmp-nvim-lua",
  -- cmp_luasnip           = "saadparwaiz1/cmp_luasnip",

  -- LSP
  mason                 = "williamboman/mason.nvim",
  lspconfig             = "neovim/nvim-lspconfig",
  mason_lspconfig       = "williamboman/mason-lspconfig.nvim",
  lightbulb             = "kosayoda/nvim-lightbulb",
  typescript_tools      = "pmizio/typescript-tools.nvim",
  sqls                  = "nanotee/sqls.nvim",
  fmt_ts_errors         = "davidosomething/format-ts-errors.nvim",
  omnisharp_ext         = "Hoffs/omnisharp-extended-lsp.nvim",
  schemastore           = "b0o/SchemaStore.nvim",
  lazydev               = "folke/lazydev.nvim",
  luvit_meta            = "Bilal2453/luvit-meta",

  -- TREE-SITTER
  treesitter            = "nvim-treesitter/nvim-treesitter",
  treesitter_comments   = "folke/ts-comments.nvim",
  fold_cycle            = "jghauser/fold-cycle.nvim",
  auto_tag              = "windwp/nvim-ts-autotag",

  -- DAP
  dap                   = "mfussenegger/nvim-dap",
  mason_dap             = "jay-babu/mason-nvim-dap.nvim",
  dap_ui                = "rcarriga/nvim-dap-ui",
  nio                   = "nvim-neotest/nvim-nio",

  -- git_conflict                = "akinsho/git-conflict.nvim",
  -- view                        = "RaafatTurki/view.nvim",
  -- lsp_overloads               = "Issafalcon/lsp-overloads.nvim",
  -- dial                        = "monaqa/dial.nvim",
  -- nvim_bqf                    = "kevinhwang91/nvim-bqf",
}

return M
