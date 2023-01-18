--- invokes various services in order.
-- @module service_loader
log = require 'logger'.log
U = require 'utils'

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
  mini = 'echasnovski/mini.nvim',
}
local plugins = {
  -- LSP:
  p.lspconfig,
  { 'jose-elias-alvarez/null-ls.nvim',
    dependencies = p.plenary,
  },
  -- LANG:
  { p.treesitter,
    build = ':TSUpdate',
  },
  { 'williamboman/mason.nvim',
    dependencies = {
      p.lspconfig,
      'williamboman/mason-lspconfig.nvim',
      'jayp0521/mason-null-ls.nvim',
    },
  },
  { 'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = p.treesitter,
  },
  { 'SmiteshP/nvim-navic',
    dependencies = p.lspconfig,
  },
  { 'b0o/schemastore.nvim',
    dependencies = p.lspconfig,
  },
  { 'folke/neodev.nvim',
    dependencies = p.lspconfig,
  },
  -- p.dap,
  -- {'rcarriga/nvim-dap-ui',                            dependencies = p.dap },
  -- PLUGINS:
  -- mini.*
  { 'RRethy/vim-illuminate' },
  p.devicons,
  { p.gitsigns,
    dependencies = p.plenary,
  },
  { 'Mofiqul/trld.nvim' },
  { 'kyazdani42/nvim-tree.lua',
    dependencies = p.devicons,
  },
  { 'akinsho/nvim-toggleterm.lua' },
  { 'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      p.plenary,
      { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    }
  },
  { 'jghauser/fold-cycle.nvim' },
  { 'Issafalcon/lsp-overloads.nvim' },
  { 'anuvyklack/fold-preview.nvim',
    dependencies = 'anuvyklack/keymap-amend.nvim',
  },
  { 'NvChad/nvim-colorizer.lua' },
  { 'folke/noice.nvim',
    dependencies = p.nui,
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
  },
  { 'stevearc/dressing.nvim' },
  -- STATUSBAR:
  { 'rebelot/heirline.nvim',
    dependencies = {
      p.devicons,
      p.gitsigns
    },
  },
  -- UNCHARTED:
  p.mini,
  { 'nvim-treesitter/playground',
    dependencies = p.treesitter
  },
  { 'mfussenegger/nvim-jdtls' },
  { 'euclio/vim-markdown-composer',
    build = 'cargo build --release'
  },
  { 'rest-nvim/rest.nvim',
    dependencies = p.plenary
  },
  { 'folke/paint.nvim' },
  { 'RaafatTurki/hex.nvim', dev = false },
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

  Plugins.devicons()
  Plugins.illuminate()
  Plugins.telescope()
  Plugins.gitsigns()
  Plugins.cmp_ls()
  Plugins.dressing()
  Plugins.toggle_term()
  Plugins.mini_starter()
  Plugins.mini_surround()
  Plugins.mini_map()
  Plugins.mini_bufremove()
  Plugins.mini_move()
  Plugins.trld()
  Plugins.fold_cycle()
  Plugins.fold_preview()
  Plugins.nvim_tree()
  Plugins.colorizer()
  Plugins.vim_markdown_composer()
  Plugins.rest()
  Plugins.paint()
  Plugins.noice()
  Plugins.hex()

  Lang.setup()

  Lsp.setup()
  Lsp.setup_servers()

  Statusbar.setup()

  Bind.setup_plugins()
end)

PluginManager.setup(plugins)
