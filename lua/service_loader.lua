--- invokes various services in order.
-- @module service_loader
Buffers = require 'services.buffers'
PluginManager = require 'plugin_manager'
Sessions = require 'services.sessions'
Bind = require 'services.bind'
Misc = require 'services.misc'
Plugins = require 'services.plugins'
Lang = require 'services.lang'
Lsp = require 'services.lsp'
Statusbar = require 'services.statusbar'

local p = {
  plenary = 'nvim-lua/plenary.nvim',
  devicons = 'kyazdani42/nvim-web-devicons',
  treesitter = 'nvim-treesitter/nvim-treesitter',
  dap = 'mfussenegger/nvim-dap',
  gitsigns = 'lewis6991/gitsigns.nvim',
  nui = 'MunifTanjim/nui.nvim',
  lspconfig = 'neovim/nvim-lspconfig',
}
local plugins = {
  -- LSP: language server protocol related
  { p.lspconfig,
    config = function()
      Features:add(FT.PLUGIN, 'nvim-lspconfig')
    end,
  },
  {'jose-elias-alvarez/null-ls.nvim',
    dependencies = p.plenary,
    config = function()
      Features:add(FT.PLUGIN, 'null-ls.nvim')
    end,
  },
  { 'williamboman/mason.nvim',
    dependencies = {
      p.lspconfig,
      'williamboman/mason-lspconfig.nvim',
      'jayp0521/mason-null-ls.nvim',
    },
    config = function()
      Features:add(FT.PLUGIN, 'mason.nvim')
    end,
  },
  { 'mfussenegger/nvim-jdtls',
    config = function()
      Features:add(FT.PLUGIN, 'nvim-jdtls')
    end
  },
  { 'b0o/schemastore.nvim',
    dependencies = p.lspconfig,
    config = function()
      Features:add(FT.PLUGIN, 'schemastore.nvim')
    end,
  },
  { 'folke/neodev.nvim',
    dependencies = p.lspconfig,
    config = function()
      -- Features:add(FT.PLUGIN, 'schemastore.nvim')
    end,
  },
  { 'Mofiqul/trld.nvim',
    config = Plugins.trld,
  },
  -- { 'Issafalcon/lsp-overloads.nvim' },
  -- LANG: treesitter and language specific plugins
  { p.treesitter,
    build = ':TSUpdate',
    config = function()
      Features:add(FT.PLUGIN, 'nvim-treesitter')
    end,
  },
  { 'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = p.treesitter,
    config = function()
      Features:add(FT.PLUGIN, 'nvim-ts-context-commentstring')
    end,
  },
  { 'SmiteshP/nvim-navic',
    dependencies = p.lspconfig,
    config = function()
      Features:add(FT.PLUGIN, 'nvim-navic')
    end,
  },
  { 'nvim-treesitter/playground',
    dependencies = p.treesitter,
    config = function()
      Features:add(FT.PLUGIN, 'playground')
    end,
  },
  { 'euclio/vim-markdown-composer',
    build = 'cargo build --release',
    config = Plugins.vim_markdown_composer,
  },
  { 'rest-nvim/rest.nvim',
    dependencies = p.plenary,
    config = Plugins.rest,
  },
  -- STATUSBAR:
  { 'rebelot/heirline.nvim',
    config = function()
      Features:add(FT.PLUGIN, 'heirline.nvim')
    end
  },
  -- PLUGINS:
  { 'echasnovski/mini.nvim',
    config = Plugins.mini_map
  },
  { 'RRethy/vim-illuminate',
    config = Plugins.illuminate
  },
  { p.gitsigns,
    dependencies = p.plenary,
    config = Plugins.gitsigns,
  },
  { 'kyazdani42/nvim-tree.lua',
    dependencies = p.devicons,
    config = Plugins.nvim_tree,
  },
  { 'akinsho/nvim-toggleterm.lua',
    config = Plugins.toggle_term,
  },
  { 'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      p.plenary,
      { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = Plugins.telescope,
  },
  { 'jghauser/fold-cycle.nvim',
    config = Plugins.fold_cycle,
  },
  { 'anuvyklack/fold-preview.nvim',
    dependencies = 'anuvyklack/keymap-amend.nvim',
    config = Plugins.fold_preview,
  },
  { 'NvChad/nvim-colorizer.lua',
    config = Plugins.colorizer,
  },
  { 'folke/noice.nvim',
    dependencies = p.nui,
    config = Plugins.noice,
  },
  { 'hrsh7th/nvim-cmp',
    dependencies = {
      'lukas-reineke/cmp-rg',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-buffer',
    },
    config = Plugins.cmp_ls,
  },
  { 'stevearc/dressing.nvim',
    config = Plugins.dressing,
  },
  { 'RaafatTurki/hex.nvim', dev = false,
    config = Plugins.hex,
  },
  -- p.dap,
  -- {'rcarriga/nvim-dap-ui',                            dependencies = p.dap },
  -- UNCHARTED:
  { 'folke/paint.nvim',
    config = Plugins.paint,
  },
}

PluginManager.event_post_complete:sub(function()
  Buffers.setup()
  Sessions.setup()
  Bind.setup()

  Bind.bind_leader()

  Misc.base()
  Misc.open_uri()
  -- Misc.color_col()
  Misc.term_smart_esc()
  Misc.disable_builtin_plugins()
  Misc.highlight_yank()
  Misc.auto_install_ts_parser()
  -- Misc.diag_on_hold()
  Misc.pets()
  Misc.buffer_edits()
  Misc.auto_create_dir()
  Misc.lorem_picsum()
  Misc.auto_gitignore_io()

  Lang.setup()

  Lsp.setup()
  Lsp.setup_servers()

  Statusbar.setup()

  Bind.setup_plugins()
end)

PluginManager.setup(plugins)
