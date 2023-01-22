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
  { p.lspconfig },
  {'jose-elias-alvarez/null-ls.nvim',
    dependencies = p.plenary,
  },
  { 'williamboman/mason.nvim',
    dependencies = {
      p.lspconfig,
      'williamboman/mason-lspconfig.nvim',
      'jayp0521/mason-null-ls.nvim',
    },
  },
  { 'mfussenegger/nvim-jdtls' },
  { 'b0o/schemastore.nvim',
    dependencies = p.lspconfig,
  },
  { 'folke/neodev.nvim',
    dependencies = p.lspconfig,
  },
  { 'Mofiqul/trld.nvim',
    config = function()
      Events.configure:sub(Plugins.trld)
    end
  },
  -- { 'Issafalcon/lsp-overloads.nvim' },
  -- LANG: treesitter and language specific plugins
  { p.treesitter,
    build = ':TSUpdate',
  },
  { 'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = p.treesitter,
  },
  { 'SmiteshP/nvim-navic',
    dependencies = p.lspconfig,
  },
  { 'nvim-treesitter/playground',
    dependencies = p.treesitter,
  },
  { 'euclio/vim-markdown-composer',
    build = 'cargo build --release',
    config = function()
      Events.configure:sub(Plugins.vim_markdown_composer)
    end
  },
  { 'rest-nvim/rest.nvim',
    dependencies = p.plenary,
    config = function()
      Events.configure:sub(Plugins.rest)
    end
  },
  -- STATUSBAR:
  { 'rebelot/heirline.nvim',
    dependencies = p.devicons,
  },
  -- PLUGINS:
  { 'echasnovski/mini.nvim',
    config = function()
      Events.configure:sub(Plugins.mini_starter)
      Events.configure:sub(Plugins.mini_surround)
      Events.configure:sub(Plugins.mini_map)
      Events.configure:sub(Plugins.mini_bufremove)
      Events.configure:sub(Plugins.mini_move)
    end
  },
  { 'RRethy/vim-illuminate',
    config = function()
      Events.configure:sub(Plugins.illuminat)
    end
  },
  { p.gitsigns,
    dependencies = p.plenary,
    config = function()
      Events.configure:sub(Plugins.gitsigns)
    end
  },
  { 'nvim-neo-tree/neo-tree.nvim',
    branch = "v2.x",
    dependencies = {
      p.plenary,
      p.nui,
      p.devicons,
      's1n7ax/nvim-window-picker',
    },
    config = function()
      Events.configure:sub(Plugins.neo_tree)
    end
  },
  { 'akinsho/nvim-toggleterm.lua',
    config = function()
      Events.configure:sub(Plugins.toggle_term)
    end
  },
  { 'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      p.plenary,
      { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = function()
      Events.configure:sub(Plugins.telescope)
    end
  },
  { 'jghauser/fold-cycle.nvim',
    config = function()
      Events.configure:sub(Plugins.fold_cycle)
    end
  },
  { 'anuvyklack/fold-preview.nvim',
    dependencies = 'anuvyklack/keymap-amend.nvim',
    config = function()
      Events.configure:sub(Plugins.fold_preview)
    end
  },
  { 'NvChad/nvim-colorizer.lua',
    config = function()
      Events.configure:sub(Plugins.colorizer)
    end
  },
  { 'folke/noice.nvim',
    dependencies = p.nui,
    config = function()
      Events.configure:sub(Plugins.noice)
    end
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
    config = function()
      Events.configure:sub(Plugins.cmp_ls)
    end
  },
  { 'stevearc/dressing.nvim',
    config = function()
      Events.configure:sub(Plugins.dressing)
    end
  },
  { 'RaafatTurki/hex.nvim', dev = true,
    config = function()
      Events.configure:sub(Plugins.hex)
    end
  },
  -- p.dap,
  -- {'rcarriga/nvim-dap-ui',                            dependencies = p.dap },
  -- UNCHARTED:
  { 'folke/paint.nvim',
    config = function()
      Events.configure:sub(Plugins.paint)
    end,
  },
}

Events.install_pre:sub(function()
  Buffers.setup()
  Bind.setup()

  Misc.base()
  Misc.open_uri()
  -- Misc.color_col()
  Misc.term_smart_esc()
  Misc.disable_builtin_plugins()
  Misc.highlight_yank()
  -- Misc.diag_on_hold()
  Misc.pets()
  Misc.buffer_edits()
  Misc.auto_create_dir()
end)

Events.install_post:sub(function()
  Sessions.setup()

  Misc.auto_install_ts_parser()
  Misc.lorem_picsum()
  Misc.auto_gitignore_io()

  Events.configure()

  Lang.setup()

  Lsp.setup()
  Lsp.setup_servers()

  Statusbar.setup()

  Bind.setup_plugins()
end)

PluginManager.setup(plugins)
